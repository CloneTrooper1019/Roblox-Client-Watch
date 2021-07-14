local FFlagDevFrameworkRefactorScrollbarColor = game:GetFastFlag("DevFrameworkRefactorScrollbarColor")

local Framework = script.Parent.Parent.Parent

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BackgroundColor3 = StyleKey.MainBackground,

		TopImage = FFlagDevFrameworkRefactorScrollbarColor and "rbxasset://textures/StudioSharedUI/ScrollBarTop.png" or "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
		MidImage = FFlagDevFrameworkRefactorScrollbarColor and "rbxasset://textures/StudioSharedUI/ScrollBarMiddle.png" or "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
		BottomImage = FFlagDevFrameworkRefactorScrollbarColor and "rbxasset://textures/StudioSharedUI/ScrollBarBottom.png" or "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",

		ScrollingEnabled = true,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 8,
		ScrollBarImageTransparency = FFlagDevFrameworkRefactorScrollbarColor and 0 or 0.5,
		ScrollBarImageColor3 = StyleKey.ScrollBar,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = common.Scroller

		return {
			Default = Default,
		}
	end
end
