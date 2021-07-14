--[[
	Provides a global EditingItem object to context.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local DraggerFramework = Plugin.Packages.DraggerFramework
local Signal = require(DraggerFramework.Utility.Signal)

local Framework = require(Plugin.Packages.Framework)
local ContextItem = Framework.ContextServices.ContextItem
local Provider = Framework.ContextServices.Provider

local EditingItemContext = ContextItem:extend("EditingItemContext")

function EditingItemContext.new()
	local self = {}

	setmetatable(self, EditingItemContext)

	self.sourceItemChangedSignal = Signal.new()

	return self
end

function EditingItemContext:setSourceItem(item)
	self.item = item
	self.sourceItemChangedSignal:Fire(item)
end

function EditingItemContext:setEditingItem(item)
	self.editingItem = item
end

function EditingItemContext:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function EditingItemContext:clear()
	self.item = nil
	self:setEditingItem(nil)
end

function EditingItemContext:getItem()
	return self.editingItem
end

function EditingItemContext:getSourceItem()
	return self.item
end

function EditingItemContext:getSourceItemChangedSignal()
	return self.sourceItemChangedSignal
end

return EditingItemContext