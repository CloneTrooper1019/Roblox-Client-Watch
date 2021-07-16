--[[
	Combines all style.lua tables in each component.
	Note that component styles expect defined StyleKeys when used in
	Stylizer. Combine this file with DarkTheme, LightTheme, or your own
	theme color using Stylizer.new(DarkTheme) and Stylizer:extend(BaseTheme).
]]

local Framework = script.Parent.Parent.Parent
local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local UIFolderData = require(Framework.UI.UIFolderData)

local ComponentSymbols = require(Framework.Style.ComponentSymbols)
local StyleKey = require(Framework.Style.StyleKey)

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local Util = Framework.Util
local Cryo = require(Util.Cryo)
local THEME_REFACTOR = require(Util.RefactorFlags).THEME_REFACTOR

if (not THEME_REFACTOR) then
	return {}
end

local styles = Cryo.Dictionary.join(Common.MainText, {
	-- Common styles
	Color = StyleKey.MainBackground,
	BorderColor = StyleKey.Border,
})

local function createComponentStyles(folderData)
	for _,folder in pairs(folderData) do
		if folder.style then
			assert(ComponentSymbols[folder.name] ~= nil, ("No Symbol was found for the component %s"):format(folder.name))
			local componentStyleFile = require(folder.style)
			styles[ComponentSymbols[folder.name]] = componentStyleFile
		end
	end
end

createComponentStyles(UIFolderData)
createComponentStyles(StudioUIFolderData)

return styles