--[[
	Matches the table structure of UILibrary's Style table. Provides a default mapping for colors

]]
local StudioStyle = {}
StudioStyle.__index = StudioStyle

-- c : StudioStyleGuideColor
-- m : StudioStyleGuideModifier
function StudioStyle.new(getColor, c, m)
	local FStringMainFont = game:GetFastString("StudioBuiltinPluginDefaultFont")

	return {
		font = Enum.Font[FStringMainFont],

		backgroundColor = getColor(c.MainBackground),
		liveBackgroundColor = Color3.new(),
		textColor = getColor(c.MainText),
		subTextColor = getColor(c.SubText),
		dimmerTextColor = getColor(c.DimmedText),

		itemColor = getColor(c.Item),
		borderColor = getColor(c.Border),

		hoveredItemColor = getColor(c.Item, m.Hover),
		hoveredTextColor = getColor(c.MainText, m.Hover),

		primaryItemColor = getColor(c.DialogMainButton),
		primaryBorderColor = getColor(c.DialogMainButton),
		primaryTextColor = getColor(c.DialogMainButtonText),

		primaryHoveredItemColor = getColor(c.DialogMainButton, m.Hover),
		primaryHoveredBorderColor = getColor(c.DialogMainButton, m.Hover),
		primaryHoveredTextColor = getColor(c.DialogMainButtonText, m.Hover),

		selectionColor = getColor(c.Item, m.Selected),
		selectionBorderColor = getColor(c.Border, m.Selected),
		selectedTextColor = getColor(c.MainText, m.Selected),

		shadowColor = getColor(c.Shadow),
		shadowTransparency = getColor(c.Shadow, m.Hover),

		separationLineColor = getColor(c.Separator),

		disabledColor = getColor(c.MainText, m.Disabled),
		errorColor = getColor(c.ErrorText),

		hoverColor = getColor(c.MainBackground, m.Hover),

		hyperlinkTextColor = getColor(c.LinkText),
	}
end

return StudioStyle