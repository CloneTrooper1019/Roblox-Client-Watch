--[[
	A rectangular drop shadow that appears behind an element.

	Props:
		Vector2 Offset = The offset of this drop shadow from the element it appears beneath.
		float Transparency = The transparency of the drop shadow, from 0 to 1.
		Color3 Color = The color of the drop shadow.
		SizePixel = The size of the drop shadow, in pixels.
		ZIndex = The render order of the drop shadow. Make sure it is behind your element.
]]

local Library = script.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local SLICE_SIZE = 8
local DROP_SHADOW_SLICE = Rect.new(SLICE_SIZE, SLICE_SIZE, SLICE_SIZE, SLICE_SIZE)

local DropShadow = Roact.PureComponent:extend("DropShadow")

function DropShadow:render()
	return withTheme(function(theme)
		local props = self.props
		local shadowTheme = theme.dropShadow

		local shadowColor = props.Color
		local shadowTransparency = props.Transparency
		local offset = props.Offset or Vector2.new()
		local shadowSize = props.SizePixel or SLICE_SIZE
		local zindex = props.ZIndex or 0

		-- SliceScale is multiplicative, so we need to normalize to the slice size
		local sliceScale = shadowSize / SLICE_SIZE

		return Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, shadowSize, 1, shadowSize),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, offset.X, 0.5, offset.Y),
			ZIndex = zindex,

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Image = shadowTheme.image,
			ImageColor3 = shadowColor,
			ImageTransparency = shadowTransparency,

			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = DROP_SHADOW_SLICE,
			SliceScale = sliceScale,
		})
	end)
end

return DropShadow
