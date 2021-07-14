--[[
	Provides a global Preview object to context.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Cryo = require(Plugin.Packages.Cryo)

local Framework = require(Plugin.Packages.Framework)
local ContextItem = Framework.ContextServices.ContextItem
local Provider = Framework.ContextServices.Provider

local PreviewContext = ContextItem:extend("PreviewContext")

function PreviewContext.new()
	local self = {}

	setmetatable(self, PreviewContext)

	self.previewAvatars = {}
	self.previewItems = {}

	return self
end

function PreviewContext:addAvatar(avatar)
	if avatar:IsA("Model") then
		table.insert(self.previewAvatars, avatar)
	end
end

function PreviewContext:getAvatars()
	return Cryo.Dictionary.join({}, self.previewAvatars)
end

function PreviewContext:addItem(item)
	if item:IsA("MeshPart") then
		table.insert(self.previewItems, item)
	end
end

function PreviewContext:getItems()
	return Cryo.Dictionary.join({}, self.previewItems)
end

function PreviewContext:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function PreviewContext:destroyItems()
	for _,instance in ipairs(self.previewItems) do
		instance:Destroy()
	end
	self.previewItems = {}
end

function PreviewContext:destroyAvatars()
	for _,instance in ipairs(self.previewAvatars) do
		instance:Destroy()
	end
	self.previewAvatars = {}
end

function PreviewContext:destroy()
	self:destroyAvatars()
	self:destroyItems()
end

return PreviewContext