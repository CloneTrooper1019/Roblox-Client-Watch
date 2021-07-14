--[[
	A Decoration image.

	Optional Props:
		string Image: The image asset itself.
		UDim2 Size: size of the image
		Color3 ImageColor3: The color tint of the image.
		Vector2 AnchorPoint: The anchor point of the image.
		UDim2 Position: position of the image
		number Rotation: rotation of the image
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		Enum.SizeConstraint SizeConstraint: the direction(s) that the image can be resized in.
		number LayoutOrder: LayoutOrder of the component.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.

	Style Values:
		Vector2 AnchorPoint: The anchor point of the image.
		Color3 Color: The color tint of the image.
		number Transparency: The transparency of the image.
		string Image: The image asset itself.
		Enum.ScaleType ScaleType: The SaleType of the image (Fit, Crop, etc).
		Rect SliceCenter: The SliceCenter rect of the image, if it is ScaleType Slice.
		UDim2 Size: size of the image
		UDim2 Position: position of the image
		Vector2 ImageRectSize: partial pixel size of the image
		Vector2 ImageRectOffset: pixel offset for rendering part of image
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Typecheck = require(Framework.Util).Typecheck
local Util = require(Framework.Util)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Image = Roact.PureComponent:extend("Image")
Typecheck.wrap(Image, script)

function Image:render()
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local color = props.ImageColor3 or style.Color
	local transparency = style.Transparency
	local image = props.Image or style.Image
	local imageRectSize = style.ImageRectSize
	local imageRectOffset = style.ImageRectOffset
	local scaleType = style.ScaleType
	local sizeConstraint = props.SizeConstraint
	local sliceCenter = style.SliceCenter
	local anchorPoint = props.AnchorPoint or style.AnchorPoint
	local position = props.Position or style.Position or UDim2.new(0, 0, 0, 0)
	local size = props.Size or style.Size or UDim2.new(1, 0, 1, 0)
	local layoutOrder = props.LayoutOrder
	local rotation = props.Rotation or style.Rotation

	return Roact.createElement("ImageLabel", {
		AnchorPoint = anchorPoint,
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		ImageTransparency = transparency,
		ImageColor3 = color,
		BorderSizePixel = 0,
		Rotation = rotation,
		Image = image,
		ImageRectSize = imageRectSize,
		ImageRectOffset = imageRectOffset,
		ScaleType = scaleType,
		SliceCenter = sliceCenter,
		SizeConstraint = sizeConstraint,
		LayoutOrder = layoutOrder,
	}, props[Roact.Children])
end

ContextServices.mapToProps(Image, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Image
