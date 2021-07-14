local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)
local Util = require(Framework.Util)
local Style = Util.Style

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Spacing = 2,
		TextColor = StyleKey.DimmedText,
		TextInputStyle = "FilledRoundedBorder",
		TextSize = 16,

		["&Error"] = {
			TextInputStyle = "FilledRoundedRedBorder",
			TextColor = StyleKey.ErrorText,
		},
	}
else
	return function(theme, getColor)
		local Default = Style.new({
			Padding = 2,
			TextColor = theme:GetColor("DimmedText"),
			TextInputStyle = "FilledRoundedBorder",
			TextSize = 16,
		})

		local Error = Style.extend(Default, {
			TextColor = theme:GetColor("ErrorText"),
			TextInputStyle = "FilledRoundedRedBorder",
		})

		return {
			Default = Default,
			Error = Error,
		}
	end
end
