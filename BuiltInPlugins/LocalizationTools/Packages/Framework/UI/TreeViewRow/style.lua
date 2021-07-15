local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local StyleKey = require(Framework.Style.StyleKey)

if THEME_REFACTOR then
	return {
		Arrow = {
			Image = "rbxasset://textures/StudioSharedUI/arrowSpritesheet.png",
			Size = 12,
			ExpandedOffset = Vector2.new(24, 0),
			CollapsedOffset = Vector2.new(12, 0),
			Color = StyleKey.MainText,
		},
		Border = StyleKey.SubBackground,
		Background = StyleKey.MainBackground,
		Indent = 17,
		[StyleModifier.Hover] = {
			Background = StyleKey.ButtonHover,
		},
		[StyleModifier.Selected] = {
			TextColor = StyleKey.DialogMainButtonText,
			Background = StyleKey.DialogMainButton,
		},
		Tooltip = {
			MaxWidth = 1000
		},
		RowHeight = 24,
		Spacing = 5,
		Padding = {
			Top = 1,
			Bottom = 1,
			Left = 5,
			Right = 5,
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
