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

if not FFlagDevFrameworkCheckbox then
	if THEME_REFACTOR then
		return {}
	else
		return function() end
	end
elseif THEME_REFACTOR then
	return {
		ImageSize = UDim2.new(0, 16, 0, 16),
		Spacing = 6,

		BackgroundStyle = {
			Background = Decoration.Image,
			BackgroundStyle = {
				Image = StyleKey.CheckboxUncheckedImage,
			},

			[StyleModifier.Selected] = {
				BackgroundStyle = {
					Image = StyleKey.CheckboxCheckedImage,
				},
			},
			[StyleModifier.Indeterminate] = {
				BackgroundStyle = {
					Image = StyleKey.CheckboxIndeterminateImage,
				},
			},
			[StyleModifier.Disabled] = {
				BackgroundStyle = {
					Image = StyleKey.CheckboxDisabledImage,
				},
			},
		}
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local themeName = theme.Name

		local checkBoxUncheckedImage = StyleValue.new("CheckBoxUncheckedImage", {
			Light = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_light.png",
			Dark = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_dark.png",
		})

		local checkBoxCheckedImage = StyleValue.new("CheckBoxCheckedImage", {
			Light = "rbxasset://textures/DeveloperFramework/checkbox_checked_light.png",
			Dark = "rbxasset://textures/DeveloperFramework/checkbox_checked_dark.png",
		})

		local checkBoxIndeterminateImage = StyleValue.new("CheckBoxIndeterminateImage", {
			Light = "rbxasset://textures/DeveloperFramework/checkbox_checked_light.png",
			Dark = "rbxasset://textures/DeveloperFramework/checkbox_checked_dark.png",
		})

		local checkBoxDisabledImage = StyleValue.new("CheckBoxDisabledImage", {
			Light = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_disabled_light.png",
			Dark = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_disabled_dark.png",
		})

		local Default = Style.extend(common.MainText, {
			Spacing = 6,
			ImageSize = UDim2.new(0, 16, 0, 16),
			Background = Decoration.Image,
			BackgroundStyle = {
				Image = checkBoxUncheckedImage:get(themeName),
			},
			[StyleModifier.Selected] = {
				BackgroundStyle = {
					Image = checkBoxCheckedImage:get(themeName),
				},
			},
			[StyleModifier.Indeterminate] = {
				BackgroundStyle = {
					Image = checkBoxIndeterminateImage:get(themeName),
				},
			},
			[StyleModifier.Disabled] = {
				BackgroundStyle = {
					Image = checkBoxDisabledImage:get(themeName),
				},
			},
		})

		return {
			Default = Default,
		}
	end
end
