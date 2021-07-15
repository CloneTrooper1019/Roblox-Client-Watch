--[[
	Mouse is a ContextItem that handles mouse icon logic for the plugin.
	The Mouse constructor expects a PluginMouse instance.
]]

local DEFAULT_CURSOR = "rbxasset://SystemCursors/Arrow"

local function getCursor(cursorString)
	if string.find(cursorString, "rbxasset://textures/")
		or string.find(cursorString, "rbxasset://SystemCursors/") then
		return cursorString
	else
		return "rbxasset://SystemCursors/" .. cursorString
	end
end

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)

local Mouse = ContextItem:extend("Mouse")

function Mouse.new(mouse)
	assert(mouse, "Mouse.new expects a PluginMouse instance.")

	local self = {
		mouse = mouse,
		cursors = {}
	}

	setmetatable(self, Mouse)
	return self
end

function Mouse:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function Mouse:get()
	return self.mouse
end

function Mouse:__updateCursor()
	local cursors = self.cursors
	local maxPriority = 1

	for priority, _ in pairs(cursors) do
		if priority > maxPriority then
			maxPriority = priority
		end
	end

	local displayCursors = cursors[maxPriority]
	if displayCursors and #displayCursors > 0 then
		self.mouse.Icon = displayCursors[#displayCursors]
	else
		self.mouse.Icon = DEFAULT_CURSOR
	end
end

function Mouse:__pushCursor(cursor, priority)
	priority = priority or 1
	local cursors = self.cursors[priority] or {}
	table.insert(cursors, getCursor(cursor))
	self.cursors[priority] = cursors

	self:__updateCursor()
end

function Mouse:__popCursor(priority)
	priority = priority or 1
	local cursors = self.cursors[priority]

	if cursors then
		table.remove(cursors, #cursors)

		if #cursors == 0 then
			self.cursors[priority] = nil
		end

		self:__updateCursor()
	end
end

function Mouse:__resetCursor()
	self.cursors = {}
	self.mouse.Icon = DEFAULT_CURSOR
end

return Mouse
