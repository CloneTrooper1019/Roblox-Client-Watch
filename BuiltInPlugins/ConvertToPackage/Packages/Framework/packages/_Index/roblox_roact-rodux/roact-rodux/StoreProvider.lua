local Roact = require(script.Parent.Parent.Roact)

local storeKey = require(script.Parent.storeKey)

local StoreProvider = Roact.Component:extend("StoreProvider")

function StoreProvider:init(props)
	local store = props.store

	if store == nil then
		error("Error initializing StoreProvider. Expected a `store` prop to be a Rodux store.")
	end

	self._context[storeKey] = store
end

function StoreProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return StoreProvider