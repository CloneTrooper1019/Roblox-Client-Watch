local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)
local Util = require(Framework.Util)
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local StyleModifier = Util.StyleModifier

if THEME_REFACTOR then
	return {
		[StyleModifier.Disabled] = {
			TextTransparency = 0.5,
		},
		["&Bold"] = {
			Font = Enum.Font.SourceSansBold
		},
		["&Normal"] = {
			Font = Enum.Font.SourceSans,
			TextSize = 22,
			TextColor3 = StyleKey.MainText,
		},
		["&Semibold"] = {
			Font = Enum.Font.SourceSansSemibold,
			TextSize = 22,
			TextColor3 = StyleKey.MainText,
		},
		["&Title"] = {
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			TextColor3 = StyleKey.TitlebarText,
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.MainText, {
			[StyleModifier.Disabled] = {
				TextTransparency = 0.5,
			},
		})

		local Bold = Style.extend(Default, {
			Font = Enum.Font.SourceSansBold
		})

		local Normal = Style.extend(Default, {
			Font = Enum.Font.SourceSans,
			TextSize = 22,
			TextColor3 = theme:GetColor("MainText"),
		})

		local Semibold = Style.extend(Default, {
			Font = Enum.Font.SourceSansSemibold,
			TextSize = 22,
			TextColor3 = theme:GetColor("MainText"),
		})

		local Title = Style.extend(Default, {
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			TextColor3 = theme:GetColor("TitlebarText"),
		})

		return {
			Title = Title,
			Semibold = Semibold,
			Normal = Normal,
			Bold = Bold,
			Default = Default,
		}
	end
end
