local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")

local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local StyleValue = Util.StyleValue
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

if THEME_REFACTOR then
	return {
		Background = Decoration.Image,
		BackgroundStyle = {
			Image = StyleKey.ToggleOffImage,
		},
		[StyleModifier.Selected] = {
			BackgroundStyle = {
				Image = StyleKey.ToggleOnImage,
			},
		},
		[StyleModifier.Disabled] = {
			BackgroundStyle = {
				Image = StyleKey.ToggleDisabledImage,
			},
		},

		["&Checkbox"] = not FFlagDevFrameworkCheckbox and {
			Background = Decoration.Image,
			BackgroundStyle = {
				Image = StyleKey.CheckboxDefaultImage,
			},
			[StyleModifier.Selected] = {
				BackgroundStyle = {
					Image = StyleKey.CheckboxSelectedImage,
				},
			},
			[StyleModifier.Disabled] = {
				BackgroundStyle = {
					Image = StyleKey.CheckboxDisabledImage,
				},
			},
		} or nil,
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local themeName = theme.Name

		local onImage = StyleValue.new("onImage", {
			Light = "rbxasset://textures/RoactStudioWidgets/toggle_on_light.png",
			Dark = "rbxasset://textures/RoactStudioWidgets/toggle_on_dark.png",
		})

		local offImage = StyleValue.new("offImage", {
			Light = "rbxasset://textures/RoactStudioWidgets/toggle_off_light.png",
			Dark = "rbxasset://textures/RoactStudioWidgets/toggle_off_dark.png",
		})

		local disabledImage = StyleValue.new("disabledImage", {
			Light = "rbxasset://textures/RoactStudioWidgets/toggle_disable_light.png",
			Dark = "rbxasset://textures/RoactStudioWidgets/toggle_disable_dark.png",
		})

		local Default = Style.extend(common.MainText, {
			Background = Decoration.Image,
			BackgroundStyle = {
				Image = offImage:get(themeName),
			},
			[StyleModifier.Selected] = {
				BackgroundStyle = {
					Image = onImage:get(themeName),
				},
			},
			[StyleModifier.Disabled] = {
				BackgroundStyle = {
					Image = disabledImage:get(themeName),
				},
			},
		})

		if FFlagDevFrameworkCheckbox then
			return {
				Default = Default,
			}
		else
			local checkboxDefaultImage = StyleValue.new("checkboxDefaultImage", {
				Light = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_light.png",
				Dark = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_dark.png",
			})

			local checkboxSelectedImage = StyleValue.new("checkboxSelectedImage", {
				Light = "rbxasset://textures/DeveloperFramework/checkbox_checked_light.png",
				Dark = "rbxasset://textures/DeveloperFramework/checkbox_checked_dark.png",
			})

			local checkboxDisabledImage = StyleValue.new("checkboxDisabledImage", {
				Light = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_disabled_light.png",
				Dark = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_disabled_dark.png",
			})

			local Checkbox = Style.new({
				Background = Decoration.Image,
				BackgroundStyle = {
					Image = checkboxDefaultImage:get(themeName),
				},
				[StyleModifier.Selected] = {
					BackgroundStyle = {
						Image = checkboxSelectedImage:get(themeName),
					},
				},
				[StyleModifier.Disabled] = {
					BackgroundStyle = {
						Image = checkboxDisabledImage:get(themeName),
					},
				},
			})

			return {
				Default = Default,
				Checkbox = Checkbox,
			}
		end
	end
end
