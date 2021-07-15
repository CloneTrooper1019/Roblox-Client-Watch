--[[
	Create a theme for a plugin by collecting all of the style.lua stylesheets for each component.

	NB: To use this, your plugin needs to use Fractal Design Pattern.
	Further reading: https://confluence.rbx.com/display/RDE/Plugin+Template+Fractal+Components

	The returned function can be used to create a real or mocked theme context item.
]]
local Framework = script.Parent.Parent
local Dash = require(Framework.packages.Dash)
local collect = Dash.collect

local Style = Framework.Style
local StudioTheme = require(Style.Themes.StudioTheme)
local ComponentSymbols = require(Style.ComponentSymbols)

--[[
	@param componentsFolder - The folder in the plugin where the components are defined i.e. Main.Src.Components
	@param style - An optional table of styles to apply to all the plugin components
	@param baseTheme - An optional theme to use instead of StudioTheme as the base
]]
local function makeTheme(componentsFolder: Folder, style: any?, baseTheme: any?)
	return function(mock: boolean)
		local theme = mock and StudioTheme.mock() or baseTheme or StudioTheme.new()
		local componentStyles = collect(componentsFolder:GetChildren(), function(_, folder: Folder)
			local style = folder:FindFirstChild("style")
			if style then
				local symbol = ComponentSymbols:add(folder.Name)
				return symbol, require(style)
			else
				return nil
			end
		end)
		return theme:extend(style or {}):extend(componentStyles)
	end
end

return makeTheme
