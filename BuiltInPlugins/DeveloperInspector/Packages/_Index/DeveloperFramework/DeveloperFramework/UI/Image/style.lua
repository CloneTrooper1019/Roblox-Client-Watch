local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Style = Util.Style

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Color = Color3.new(1, 1, 1), -- Full white so image is uncolored
	}
else
	return function(theme, getColor)
		local Default = Style.new({
			Color = Color3.new(1, 1, 1), -- Full white so image is uncolored
		})

		return {
			Default = Default,
		}
	end
end
