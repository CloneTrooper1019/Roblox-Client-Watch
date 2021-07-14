--[[
	The StoryMiddleware wraps each DeveloperFramework Roact story in a typical context stack.
	These can always be overridden if need be. For example, if you need to extend the theme for
	a demonstration, you can do so by providing it again lower down in the stack.
]]
local Framework = script.Parent.Parent
local Packages = Framework.Parent

-- All stories use the theme refactor
local RefactorFlags = require(Framework.Util.RefactorFlags)
RefactorFlags.THEME_REFACTOR = true

local Roact = require(Packages.Roact)

local ContextServices = require(Framework.ContextServices)
local Analytics = ContextServices.Analytics
local Localization = ContextServices.Localization
local Focus = ContextServices.Focus
local Mouse = ContextServices.Mouse
local Plugin = ContextServices.Plugin

local ThemeSwitcher = require(Framework.Style.ThemeSwitcher)
local Resources = require(Framework.Resources)

local function StoryMiddleware(story)
	-- Stories use the DevFramework localization
	local localization = Localization.new({
		stringResourceTable = Resources.TranslationDevelopmentTable,
		translationResourceTable = Resources.TranslationReferenceTable,
		pluginName = "Storybook",
		libraries = {
			[Resources.LOCALIZATION_PROJECT_NAME] = {
				stringResourceTable = Resources.TranslationDevelopmentTable,
				translationResourceTable = Resources.TranslationReferenceTable,
			},
		},
	})
	-- Stories use the ThemeSwitcher theme
	local themeContext = ThemeSwitcher.new()

	return function(storyProps)
		-- Update the theme if the storybook theme has changed
		ThemeSwitcher.setTheme(storyProps.theme)
		-- Real or mock context items depending on current capability
		local contextItems = {
			themeContext,
			localization,
			Focus.new(storyProps.focus),
			Plugin.new(storyProps.plugin),
			Mouse.new(storyProps.plugin:GetMouse()),
			Analytics.mock()
		}
		return ContextServices.provide(contextItems, {
			Child = Roact.createElement(story, storyProps)
		})
	end
end

return StoryMiddleware
