local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Arrow = {
			Image = "rbxasset://textures/StudioSharedUI/arrowSpritesheet.png",
			Size = 12,
			ExpandedOffset = Vector2.new(24, 0),
			CollapsedOffset = Vector2.new(12, 0),
			Color = StyleKey.MainText,
		},
		Indent = 20,
		CellSpacing = 5,
		CellPadding = {
			Top = 1,
			Bottom = 1,
			Left = 5,
			Right = 5,
		},
		IconSize = 24,
	}
else
	return function(theme, getColor)
		-- Theme1 Not Supported
		local Default = Style.new({})
		return {
			Default = Default,
		}
	end
end
