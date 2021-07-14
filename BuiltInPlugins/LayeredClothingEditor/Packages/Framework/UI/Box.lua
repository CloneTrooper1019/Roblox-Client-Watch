--[[
	A simple, solid color Decoration.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.

	Style Values:
		Color3 Color: The color of the box.
		number Transparency: The transparency of the box.
		Color3 BorderColor: The color of the border.
		number BorderSize: the size of the border.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local Box = Roact.PureComponent:extend("Box")
Typecheck.wrap(Box, script)

function Box:render()
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local color = style.Color
	local transparency = style.Transparency
	local borderColor = style.BorderColor
	local borderSize = style.BorderSize or 0

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = color,
		BackgroundTransparency = transparency,
		BorderColor3 = borderColor,
		BorderSizePixel = borderSize,
	}, props[Roact.Children])
end

ContextServices.mapToProps(Box, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Box
