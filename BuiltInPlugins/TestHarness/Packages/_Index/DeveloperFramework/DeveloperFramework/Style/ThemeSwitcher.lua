--[[
	ThemeSwitcher is a DeveloperFramework theme that can be included in place of StudioTheme.
	For example, instead of `StudioTheme.new()`, use `ThemeSwitcher.new()`.

	It has methods setTheme(name: string) and getThemeName() to let developers programatically change
	or query the current theme. This is used in the Developer Storybook to let stories dynamically
	change which theme they are displaying under in the plugin itself.
]]
local Framework = script.Parent.Parent

local Signal = require(Framework.Util.Signal)
local Style = Framework.Style
local DarkTheme = require(Style.Themes.DarkTheme)
local LightTheme =  require(Style.Themes.LightTheme)
local createDefaultTheme =  require(Style.createDefaultTheme)
local getStudioTheme = function()
	local ok, theme = pcall(function()
		return settings().Studio.Theme.Name
	end)
	if not ok then
		return "Dark"
	else
		return theme
	end
end

local themeSignal = Signal.new()
pcall(function()
	settings().Studio.ThemeChanged:Connect(function()
		themeSignal:Fire()
	end)
end)

local ThemeSwitcher = {
	current = "Default",
	themesList = {
		Dark = DarkTheme,
		Light = LightTheme
	},
	themeChangedConnection = themeSignal
}
function ThemeSwitcher.getThemeName()
	if ThemeSwitcher.current == "Default" then
		return getStudioTheme()
	else
		return ThemeSwitcher.current
	end
end

function ThemeSwitcher.setTheme(name: string)
	ThemeSwitcher.current = name
	themeSignal:Fire()
end

function ThemeSwitcher.new()
	return createDefaultTheme(ThemeSwitcher)
end

return ThemeSwitcher
