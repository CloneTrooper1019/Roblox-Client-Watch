--[[
	Returns a new read-only view of _object_ which prevents any values from being changed.

	@param name The name of the object for improved error message readability.
	@param throwIfMissing If `true` then access to a missing key will also throw.
	
	@note
	Unfortunately you cannot iterate using `pairs` or `ipairs` on frozen objects because Luau
	doesn't support defining these custom iterators in metatables.

	@example
	local drink = freeze("Ice Cream", {
		flavor = "mint",
		topping = "sprinkles"
	}, true)
	print(drink.flavor) --> "mint"
	drink.flavor = "vanilla"
	--!> ReadonlyKey: Attempt to write to readonly key "flavor" (a string) of frozen object "Ice Cream"`
	print(drink.syrup) --> nil
	--!> `MissingKey: Attempt to read missing key "syrup" (a string) of frozen object "Ice Cream"`
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local Error = require(Dash.Error)
local assertEqual = require(Dash.assertEqual)
local format = require(Dash.format)

-- TODO Luau: Improve type inference to make these not need to be any
local ReadonlyKey: any = Error.new("ReadonlyKey", "Attempted to write to readonly key {key:?} of frozen object {objectName:?}")
local MissingKey: any = Error.new("MissingKey", "Attempted to read missing key {key:?} of frozen object {objectName:?}")

-- TODO Luau: Support generic functions
-- TODO Luau: Support generic extends syntax
-- TYPED: local function freeze<T extends Types.Table>(objectName: string, object: T, throwIfMissing: boolean?): T
local function freeze(objectName: string, object: Types.Table, throwIfMissing: boolean?)
	assertEqual(typeof(objectName), "string", [[Attempted to call Dash.freeze with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(object), "table", [[Attempted to call Dash.freeze with argument #2 of type {left:?} not {right:?}]])
	-- We create a proxy so that the underlying object is not affected
	local proxy = {}
	setmetatable(
		proxy,
		{
			__index = function(_, key: any)
				local value = object[key]
				if value == nil and throwIfMissing then
					-- Tried to read a key which isn't present in the underlying object
					MissingKey:throw({
						key = key,
						objectName = objectName
					})
				end
				return value
			end,
			__newindex = function(_, key: any)
				-- Tried to write to any key
				ReadonlyKey:throw({
					key = key,
					objectName = objectName
				})
			end,
			__len = function()
				return #object
			end,
			__tostring = function()
				return format("Frozen({})", objectName)
			end,
			__call = function(_, ...)
				-- TODO Luau: Gated check for if a function has a __call value
				local callable: any = object
				return callable(...)
			end
		}
	)
	return proxy
end

return freeze