local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Color = StyleKey.Border,
		StretchMargin = 0,
		Weight = 1
	}
else
	return function(theme, getColor)

		local Default = Style.new({
			Color = theme:GetColor("Border"),
			StretchMargin = 0,
			Weight = 1
		})

		return {
			Default = Default,
		}
	end
end
