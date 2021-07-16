local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

if THEME_REFACTOR then
	return {
		Color = StyleKey.MainBackground,
		BorderColor = StyleKey.Border,
		Transparency = 0,
		BorderTransparency = 0,
		BackgroundImage = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
		BorderImage = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
		SliceCenter = Rect.new(3, 3, 13, 13),
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.Background, common.Border, {
			Transparency = 0,
			BorderTransparency = 0,
			BackgroundImage = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
			BorderImage = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
			SliceCenter = Rect.new(3, 3, 13, 13),
		})

		return {
			Default = Default,
		}
	end
end
