local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local StyleKey = require(Framework.Style.StyleKey)

if THEME_REFACTOR then
	return {
		BorderSize = 1,
		Spacing = 5,
		Padding = {
			Left = 20,
			Top = 4,
			Bottom = 0,
			Right = 20,
		},
		TopLineHeight = 3,
		Color = StyleKey.ButtonText,
		BackgroundColor = StyleKey.SubBackground,
		BorderColor = StyleKey.SubBackground,
		TopLineColor = StyleKey.DialogMainButton,
		BottomLineColor = StyleKey.Border,
		[StyleModifier.Hover] = {
			Color = StyleKey.DialogMainButton,
		},
		[StyleModifier.Selected] = {
			BottomLineColor = StyleKey.SubBackground,
			BackgroundColor = StyleKey.MainBackground,
			BorderColor = StyleKey.Border,
		},
		[StyleModifier.Disabled] = {
			Color = StyleKey.ButtonTextDisabled,
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		return {
			Default = common.MainText,
		}
	end
end
