--[[
	A simple border to separate elements.

	Props:
		Enum DominantAxis = Specifies whether the separator fills the
			space horizontally or vertically. Width will make the separator
			fill the horizontal space, and Height will make the separator
			fill the vertical space.
		Weight = The thickness of the separator line.
		Padding = The padding in pixels to subtract from either side of
			the separator's dominant axis.

		Position = The position of the center of the separator.
		LayoutOrder = The order in which the separator appears in a UILayout.
		ZIndex = The render order of the separator.
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local function Separator(props)
	local dominantAxis = props.DominantAxis or Enum.DominantAxis.Width
	local position = props.Position
	local weight = props.Weight or 1
	local padding = props.Padding or 0
	local zIndex = props.ZIndex
	local layoutOrder = props.LayoutOrder

	local size
	if dominantAxis == Enum.DominantAxis.Width then
		size = UDim2.new(1, -padding * 2, 0, weight)
	else
		size = UDim2.new(0, weight, 1, -padding * 2)
	end

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = size,
			Position = position,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = theme.separator.lineColor,
			BorderSizePixel = 0,
			ZIndex = zIndex,
			LayoutOrder = layoutOrder,
		})
	end)
end

return Separator