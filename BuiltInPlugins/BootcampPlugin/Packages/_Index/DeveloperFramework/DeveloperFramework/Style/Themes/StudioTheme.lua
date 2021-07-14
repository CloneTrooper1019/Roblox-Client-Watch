--[[
	The Default theme for Studio.
]]

local Framework = script.Parent.Parent.Parent
local DarkTheme =  require(Framework.Style.Themes.DarkTheme)
local LightTheme =  require(Framework.Style.Themes.LightTheme)
local createDefaultTheme = require(Framework.Style.createDefaultTheme)
local Util = require(Framework.Util)
local Cryo = Util.Cryo
local FlagsList = Util.Flags.new({
	FFlagToolboxReplaceUILibraryComponentsPt1 = {"ToolboxReplaceUILibraryComponentsPt1"},
})

local getThemeName = function()
	return settings().Studio.Theme.Name
end

local StudioTheme = {}

function StudioTheme.new(darkThemeOverride, lightThemeOverride)
	local darkTheme = DarkTheme
	if darkThemeOverride then
		darkTheme = Cryo.Dictionary.join(DarkTheme, darkThemeOverride)
	end

	local lightTheme = LightTheme
	if lightThemeOverride then
		lightTheme = Cryo.Dictionary.join(LightTheme, lightThemeOverride)
	end

	local themeProps = {
		getThemeName = getThemeName,
		themesList = {
			["Dark"] = darkTheme,
			["Light"] = lightTheme,
		},
		themeChangedConnection = settings().Studio.ThemeChanged,
	}
	return createDefaultTheme(themeProps)
end

function StudioTheme.mock(themeOverride)
	local darkTheme = DarkTheme
	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt1") and themeOverride then
		darkTheme = Cryo.Dictionary.join(DarkTheme, themeOverride)
	end

	local themeProps = {
		getThemeName = function() return "Dark" end,
		themesList = {
			Dark = darkTheme,
		},
	}
	return createDefaultTheme(themeProps)
end

return StudioTheme