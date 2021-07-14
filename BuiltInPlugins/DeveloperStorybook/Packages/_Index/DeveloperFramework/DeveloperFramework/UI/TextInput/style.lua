local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)
local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)

local roundedBorderPadding = {
	Left = 10,
	Top = 5,
	Right = 10,
	Bottom = 5
}

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	return {
		PlaceholderTextColor = StyleKey.DimmedText,
		useRoundBox = false,

		["&RoundedBorder"] = {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			BackgroundStyle = RoundBox,
			[StyleModifier.Hover] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					BorderColor = StyleKey.DialogMainButton,
				})
			},
		},

		["&FilledRoundedBorder"] = {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				Color = StyleKey.InputFieldBackground,
			}),
			[StyleModifier.Selected] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Color = StyleKey.InputFieldBackground,
					BorderColor = StyleKey.DialogMainButton,
				})
			},
		},

		["&FilledRoundedRedBorder"] = {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				Color = StyleKey.InputFieldBackground,
				BorderColor = StyleKey.ErrorText,
			}),
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.MainText, common.Border, {
			PlaceholderTextColor = theme:GetColor("DimmedText"),
			useRoundBox = false,
		})

		local roundBox = RoundBox(theme, getColor)

		local RoundedBorder = Style.extend(Default, {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			BackgroundStyle = roundBox.Default,
			[StyleModifier.Hover] = {
				BackgroundStyle = Style.extend(roundBox.Default, common.BorderHover)
			},
		})

		local FilledRoundedBorder = Style.extend(Default, {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			Color = theme:GetColor("InputFieldBackground"),
			BackgroundStyle = Style.extend(roundBox.Default, {
				Color = theme:GetColor("InputFieldBackground"),
			}),
		})

		local FilledRoundedRedBorder = Style.extend(Default, {
			useRoundBox = true,
			Padding = roundedBorderPadding,
			BackgroundStyle = Style.extend(roundBox.Default, {
				Color = theme:GetColor("InputFieldBackground"),
				BorderColor = theme:GetColor("ErrorText"),
			}),
		})

		return {
			Default = Default,
			RoundedBorder = RoundedBorder,
			FilledRoundedBorder = FilledRoundedBorder,
			FilledRoundedRedBorder = FilledRoundedRedBorder,
		}
	end
end
