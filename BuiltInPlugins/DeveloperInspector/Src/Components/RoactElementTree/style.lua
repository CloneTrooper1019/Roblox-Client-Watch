local Plugin = script.Parent.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local StyleKey = Framework.Style.StyleKey

return {
	RowHeight = 24,
	HoverColor = StyleKey.ButtonHover,
	SelectedColor = StyleKey.DialogMainButton,
	SelectedTextColor = StyleKey.DialogMainButtonText,
	HeadingColor = StyleKey.CategoryItem,
	BorderColor = StyleKey.Border,
	Indent = 20,
	IconPadding = 5,
	Arrow = {
		Image = "rbxasset://textures/StudioSharedUI/arrowSpritesheet.png",
		Size = 12,
		ExpandedOffset = Vector2.new(24, 0),
		CollapsedOffset = Vector2.new(12, 0),
		Color = StyleKey.MainText,
	},
}
