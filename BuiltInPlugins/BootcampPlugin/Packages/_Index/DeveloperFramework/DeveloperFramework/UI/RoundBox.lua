--[[
	A round Box decoration with a border.

	Optional Props:
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.

	Style Values:
		Color3 Color: The color tint of the image.
		Color3 BorderColor: The color tint of the border.
		number Transparency: The transparency of the image.
		number BorderTransparency: The transparency of the border.
		string BackgroundImage: The background image.
		string BorderImage: The border image.
		Rect SliceCenter: The slice center.
		number ZIndex: The render index of this component.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local RoundBox = Roact.PureComponent:extend("RoundBox")
Typecheck.wrap(RoundBox, script)

function RoundBox:render()
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local color = style.Color
	local borderColor = style.BorderColor
	local transparency = style.Transparency
	local borderTransparency = style.BorderTransparency
	local backgroundImage = style.BackgroundImage
	local borderImage = style.BorderImage
	local sliceCenter = style.SliceCenter
	local zIndex = style.ZIndex

	return Roact.createElement("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ImageTransparency = transparency,
		ImageColor3 = color,
		BorderSizePixel = 0,
		Image = backgroundImage,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = sliceCenter,
		ZIndex = zIndex
	}, {
		Border = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ImageTransparency = borderTransparency,
			ImageColor3 = borderColor,
			BorderSizePixel = 0,
			Image = borderImage,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = sliceCenter,
		}, props[Roact.Children])
	})
end

ContextServices.mapToProps(RoundBox, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return RoundBox
