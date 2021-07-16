--[[
	A stub theme for use in embedded DeveloperFramework.
	The theme can be switched programatically using theme:changeTheme
]]
local Framework = script.Parent.Parent.Parent
local DarkTheme =  require(Framework.Style.Themes.DarkTheme)
local LightTheme =  require(Framework.Style.Themes.LightTheme)
local createDefaultTheme = require(Framework.Style.createDefaultTheme)
local Dash = require(Framework.packages.Dash)
local Signal = require(Framework.Util.Signal)

local join = Dash.join

local Super = require(script.Parent.StudioTheme_stubbed :: any)

function Super.new(darkThemeOverride, lightThemeOverride)
	local darkTheme = join(DarkTheme, darkThemeOverride)
	local lightTheme = join(LightTheme, lightThemeOverride)
	local currentThemeName = "Light"
	local themeChanged = Signal.new()
	local themeProps = {
		getThemeName = function()
			return currentThemeName
		end,
		themesList = {
			["Dark"] = darkTheme,
			["Light"] = lightTheme,
		},
		themeChangedConnection = themeChanged
	}
	local theme = createDefaultTheme(themeProps)
	function theme:changeTheme(themeName: string)
		currentThemeName = themeName
		themeChanged:Fire(themeName)
	end
	return theme
end

return Super