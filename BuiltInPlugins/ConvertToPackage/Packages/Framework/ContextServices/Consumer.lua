--[[
	See ContextServices.mapToProps.
	You shouldn't use a Consumer in your plugin's code! Consumer is
	simply a helper component used by mapToProps.

	A generic consumer that is capable of listening to signals
	from one or multiple updating Context items.

	Required Props:
		table ContextMap:
			This table is used to pull items from context
			and place them into a table based on name.
			Will pull the current Theme and Localization from context,
			and call Render with a table that has replaced the entries
			with the actual values from context.

		callback Render: A callback used to render
			once the values have been pulled from Context and mapped
			based on the ContextMap.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Typecheck = require(Framework.Util).Typecheck

local Consumer = Roact.PureComponent:extend("Consumer")
Typecheck.wrap(Consumer, script)

function Consumer:init(props)
	local contextMap = props.ContextMap

	self.state = {}
	self.connections = {}

	for target, contextItem in pairs(contextMap) do
		local source = contextItem.Key

		-- Source should be a key at this point so that it can be used to index into context.
		assert(type(source) == "userdata", "ContextMap expects a <string><ContextItem> mapping.")
		assert(self._context[source] ~= nil,
			string.format("The ContextItem at %s was not provided.", tostring(source)))

		local item = self._context[source]
		self.state[target] = item.value

		-- The Consumer will re-render when any of its consumed ContextItems change.
		if item.updateSignal then
			self.connections[target] = item.updateSignal:Connect(function(newValue)
				self:setState({
					[target] = newValue,
				})
			end)
		end
	end
end

function Consumer:render()
	local renderFunc = self.props.Render
	return renderFunc(self.state)
end

function Consumer:willUnmount()
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
end

return Consumer
