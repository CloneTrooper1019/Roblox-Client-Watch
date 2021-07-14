--[[
	A ContextItem that allows Rodux stores to be provided using
	ContextServices.provide. This is used in place of a RoactRodux
	StoreProvider.

	RoactRodux.connect should still be called separately from
	ContextServices.mapToProps. This allows you to take advantage of
	the performance benefits that connect offers and to define the
	mapStateToProps and mapDispatchToProps functions.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local RoactRodux = require(Framework.Parent.RoactRodux)
local ContextItem = require(Framework.ContextServices.ContextItem)

local Store = ContextItem:extend("Store")

function Store.new(store)
	assert(store, "Store.new: Expected a Rodux store.")
	local self = {
		store = store,
	}

	setmetatable(self, Store)
	return self
end

function Store:createProvider(root)
	return Roact.createElement(RoactRodux.StoreProvider, {
		store = self.store,
	}, {root})
end

return Store
