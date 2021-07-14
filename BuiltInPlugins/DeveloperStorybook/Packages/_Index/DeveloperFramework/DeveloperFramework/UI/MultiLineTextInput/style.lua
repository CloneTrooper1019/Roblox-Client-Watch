local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBoxStyle = require(UIFolderData.RoundBox.style)
local RoundBox = require(Framework.UI.RoundBox)

local ScrollingFrame = require(UIFolderData.ScrollingFrame.style)

local roundedBorderPadding = {
	Bottom = 10,
	Left = 10,
	Right = 10,
	Top = 10,
}

if THEME_REFACTOR then
	return {
		ScrollBarOffset = 9,
		Padding = roundedBorderPadding,
		Font = Enum.Font.SourceSans,
		TextSize = 18,
		ScrollerStyle = Cryo.Dictionary.join(ScrollingFrame, {
			ScrollBarImageColor3 = StyleKey.ScrollBar,
		}),

		["&FilledRoundedBorder"] = {
			Background = RoundBox,
			BackgroundStyle = Cryo.Dictionary.join(RoundBoxStyle, {
				Color = StyleKey.InputFieldBackground,
			}),
			[StyleModifier.Selected] = {
				BackgroundStyle = Cryo.Dictionary.join(RoundBoxStyle, {
					BorderColor = StyleKey.DialogMainButton,
					Color = StyleKey.InputFieldBackground,
				}),
			},
		},
		["&FilledRoundedRedBorder"] = {
			Background = RoundBox,
			BackgroundStyle = Cryo.Dictionary.join(RoundBoxStyle, {
				BorderColor = StyleKey.ErrorText,
				Color = StyleKey.InputFieldBackground,
			}),
		},
	}
else
	return function(theme, getColor)
		local Default = Style.extend({
			ScrollBarOffset = 9,
			Font = Enum.Font.SourceSans,
			Padding = roundedBorderPadding,
			TextSize = 18,
		})

		local roundBox = RoundBoxStyle(theme, getColor)

		local FilledRoundedBorder = Style.extend(Default, {
			BackgroundStyle = Style.extend(roundBox.Default, {
				Color = theme:GetColor("InputFieldBackground"),
			}),
		})

		local FilledRoundedRedBorder = Style.extend(Default, {
			BackgroundStyle = Style.extend(roundBox.Default, {
				Color = theme:GetColor("InputFieldBackground"),
				BorderColor = theme:GetColor("ErrorText"),
			}),
		})

		return {
			Default = Default,
			FilledRoundedBorder = FilledRoundedBorder,
			FilledRoundedRedBorder = FilledRoundedRedBorder,
		}
	end
end
