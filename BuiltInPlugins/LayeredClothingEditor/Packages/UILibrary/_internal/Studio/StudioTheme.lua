--[[
	Wraps theme colors and update logic for Roblox Studio.
	Plugins are responsible for making a wrapper around this StudioTheme that
	defines a createValues function. This function maps Studio theme enums
	to named table entries which can be used in the plugin's theme.

	Example usage (a Theme.lua module in your plugin):

	local StudioTheme = require(Plugin.UILibrary.Studio.StudioTheme)
	local Theme = {}

	function Theme.createValues(getColor, c, m)
		return {
			backgroundColor = getColor(c.MainBackground),
		}
	end

	function Theme.new()
		return StudioTheme.new(Theme.createValues)
	end

	return Theme
]]

game:DefineFastFlag("FixMockStudioTheme", false)

local Library = script.Parent.Parent
local join = require(Library.join)
local Signal = require(Library.Utils.Signal)

local StudioTheme = {}
StudioTheme.__index = StudioTheme

function StudioTheme.new(createValues, overrideSignal)
	local self = {
		getTheme = function()
			return settings().Studio.Theme
		end,

		createValues = function(...)
			return createValues(...)
		end,

		valuesChanged = Signal.new(),
		values = {},
		themeChangedConnection = nil,
	}

	setmetatable(self, StudioTheme)

	if overrideSignal then
		self.themeChangedConnection = overrideSignal:Connect(function()
			self:recalculateTheme()
		end)
	else
		self.themeChangedConnection = settings().Studio.ThemeChanged:Connect(function()
			self:recalculateTheme()
		end)
	end

	self:recalculateTheme()

	return self
end

function StudioTheme:connect(...)
	return self.valuesChanged:connect(...)
end

function StudioTheme:destroy()
	if self.themeChangedConnection then
		self.themeChangedConnection:Disconnect()
	end
end

function StudioTheme:update(changedValues)
	self.values = join(self.values, changedValues)

	if self.valuesChanged then
		self.valuesChanged:fire(self.values)
	end
end

function StudioTheme:recalculateTheme()
	local theme = self.getTheme()

	-- Shorthands for getting a color
	local c = Enum.StudioStyleGuideColor
	local m = Enum.StudioStyleGuideModifier

	local function getColor(...)
		return theme:GetColor(...)
	end

	local newValues = self.createValues(getColor, c, m)

	self:update(newValues)
end

function StudioTheme.newDummyTheme(createValues)
	local self = {
		getTheme = function()
			return {
				GetColor = function()
					return Color3.new()
				end,
			}
		end,

		createValues = function(...)
			return createValues(...)
		end,

		valuesChanged = Signal.new(),
		values = {},
	}

	setmetatable(self, StudioTheme)

	if game:GetFastFlag("FixMockStudioTheme") then
		local newValues = self.createValues(function()
			return self.getTheme():GetColor()
		end, {}, {})

		self:update(newValues)
	else
		self:recalculateTheme()
	end

	return self
end

return StudioTheme
