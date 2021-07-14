local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Style = Util.Style

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		ItemOffset = 12,
		MarkerImage = "rbxasset://textures/StudioSharedUI/dot.png",
		MarkerSize = 4,
		Padding = 6,
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.MainText, {
			ItemOffset = 12,
			MarkerImage = "rbxasset://textures/StudioSharedUI/dot.png",
			MarkerSize = 4,
			Padding = 6,
		})

		return {
			Default = Default,
		}
	end
end
