--[[
	A base ContextItem used to create new items which will go into Context.
	Use the extend function to extend this class, then override the createProvider function.
	The createProvider function takes a root of a Roact tree, and creates a Provider
	above the root.

	After overriding createProvider and defining a "new" function, you can define
	any instance functions on the item you created. These functions can then
	be called from anywhere in the Roact tree after using mapToProps.

	Example:
		local MyItem = ContextItem:extend("MyItem")

		function MyItem.new(item)
			local self = {
				item = item,
			}

			setmetatable(self, MyItem)
			return self
		end

		function MyItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
			}, {root})
		end

		function MyItem:get()
			return self.item
		end
]]

local Framework = script.Parent.Parent
local Util = require(Framework.Util)
local Symbol = Util.Symbol
local Signal = Util.Signal

local Roact = require(Framework.Parent.Roact)
local Provider = require(Framework.ContextServices.Provider)

local contextItemMetatable = {}

function contextItemMetatable:__tostring()
	return self.__name
end

local ContextItem = {}
ContextItem.__index = ContextItem
setmetatable(ContextItem, contextItemMetatable)

local missingCreateProviderMessage = [[
The ContextItem %q is missing the `createProvider` method.
`createProvider` must be defined when creating a Context item!]]

--[[
	A method called to create a new ContextItem class.
]]
function ContextItem:extend(name)
	assert(typeof(name) == "string", "ContextItem class name must be a string")

	local class = {}

	for key, value in pairs(self) do
		class[key] = value
	end

	class.__index = class
	class.__name = name
	class.Key = Symbol.named(name)

	setmetatable(class, contextItemMetatable)

	return class
end

--[[
	Creates a Provider for this context item which will be used
	to provide it to context.

	Expected Parameters:
		Element root = The root element to place the provider above.

	Returns:
		A Provider element which provides self and passes {root} as its child.
]]
function ContextItem:createProvider()
	local message = missingCreateProviderMessage:format(
		tostring(self)
	)

	error(message, 0)
end

--[[
	Cleans up the context item (e.g. disconnecting from events).
	Optional override
]]
function ContextItem:destroy()
end

function ContextItem:__tostring()
	return tostring(self.__name)
end

--[[
	Creates a simple ContextItem that wraps the object passed to its constructor.
	Provides :get() method to get the wrapped object in components that need it.

	Required Parameters:
		string name: Name of the Context item

	Optional Parameters:
		table options: A table of optional parameters
			callback getValues: Used to get return value of ContextItem:get().
				If not provided, then ContextItem:get() just returns the object this context item wraps.
			callback getChangedSignal: any => Signal optional
				Should return a signal for this context item to connect to. When that signal fires, this context item updates.
				If not provided, then the context item will be static
			callback verifyNewItem: A callback fired when the simple ContextItem is being created for verification purposes.
			callback destroy: Optional function to destroy the wrapped object
]]
function ContextItem:createSimple(name, options)
	assert(name, "ContextItem:createSimple expects a name parameter")
	assert(typeof(name) == "string", "ContextItem:createSimple expects the name parameter to be a string")
	if options then
		assert(typeof(options) == "table", "ContextItem:createSimple expects the options parameter to be either nil or a table")
	end
	local SimpleContextItem = ContextItem:extend(name)

	function SimpleContextItem.new(obj)
		if options and options.verifyNewItem then
			options.verifyNewItem(obj)
		end
		local self = setmetatable({
			_obj = obj,
		}, SimpleContextItem)

		local changedSignal = options and options.getChangedSignal and options.getChangedSignal(obj)
		if changedSignal then
			self._updateSignal = Signal.new()
			self._connection = changedSignal:Connect(function()
				self._updateSignal:Fire(self)
			end)
		end

		return self
	end

	function SimpleContextItem:destroy()
		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
		end

		if options.destroy then
			options.destroy(self._obj)
		end
		self._obj = nil
	end

	function SimpleContextItem:get()
		return options and options.getValues and options.getValues(self._obj) or self._obj
	end

	function SimpleContextItem:createProvider(root)
		return Roact.createElement(Provider, {
			ContextItem = self,
			UpdateSignal = self._updateSignal,
		}, {root})
	end

	return SimpleContextItem
end

return ContextItem
