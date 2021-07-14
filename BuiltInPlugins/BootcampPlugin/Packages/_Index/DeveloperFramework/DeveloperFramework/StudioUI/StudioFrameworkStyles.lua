--[[
	Provides a default implementation of FrameworkStyles, assuming
	that the current environment is a Studio plugin.

	All components in the framework will be functional using the default
	values that this theme creates when calling StudioFrameworkTheme.new().
	You cannot override the values in the returned theme, but you can use
	StyleTable.extend to create your own styles for components
	if you need to implement a special color scheme or design.

	Usage:
		-- This example adds default style values for all
		-- DeveloperFramework components in the Roact tree,
		-- and reacts to the Studio theme changing!
		local Theme = ContextServices.Theme

		local function makeTheme()
			return Theme.new(function(theme, getColor)
				return {
					Framework = StudioFrameworkStyles.new(theme, getColor),
				}
			end)
		end

		local theme = makeTheme()
		ContextServices.provide({theme}, {
			-- My Roact tree
		})
]]

local Framework = script.Parent.Parent

local UI = require(Framework.UI)
local UIFolderData = require(Framework.UI.UIFolderData)
local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local Util = require(Framework.Util)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local FrameworkStyles = UI.FrameworkStyles
local StyleTable = Util.StyleTable

local StudioFrameworkStyles = {}


function StudioFrameworkStyles.new(theme, getColor)
	if THEME_REFACTOR then
		return {}
	end

	assert(theme, "StudioFrameworkStyles.new expects a 'theme' parameter.")
	assert(type(getColor) == "function", "StudioFrameworkStyles.new expects a 'getColor' function.")
	local frameworkStyles = FrameworkStyles.new()

	local styles = {}
	local styleScripts = script:GetChildren()

	local function loadStyle(contents)
		assert(styles[contents.name] == nil,
			string.format("Style name collision with element named '%s'", contents.name))

		local styleScript = contents.style
		if styleScript then
			local createStyle = require(styleScript)
			styles[contents.name] = createStyle(theme, getColor)
		end
	end

	-- Common Styles
	for _, styleScript in ipairs(styleScripts) do
		local createStyle = require(styleScript)
		styles[styleScript.Name] = createStyle(theme, getColor)
	end

	-- UI Styles
	for _, contents in pairs(UIFolderData) do
		loadStyle(contents)
	end

	-- Studio UI Styles
	for _, contents in pairs(StudioUIFolderData) do
		loadStyle(contents)
	end

	return StyleTable.extend(frameworkStyles, styles)
end

return StudioFrameworkStyles
