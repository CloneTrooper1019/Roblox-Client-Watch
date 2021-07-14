--[[
	A toggle button that renders a Background for its on, off, and disabled states.
	It wraps Button and updates Button's styleModifer accordingly.

	Required Props:
		callback OnClick: The function that will be called when this button is clicked to turn on and off.

	Optional Props:
		Style Style: The style with which to render this component.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		boolean Disabled: Whether or not this button can be clicked.
		number LayoutOrder: The layout order of this component.
		UDim2 Position: The position of this component.
		boolean Selected: whether the button should be on or off.
		UDim2 Size: The size of this component.
		Style Style: The style with which to render this component.
		string Text: A text to be displayed over the image if any.
		number ZIndex: The render index of this component.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Button = require(Framework.UI.Button)
local HoverArea = require(Framework.UI.HoverArea)
local StyleModifier = Util.StyleModifier

local ToggleButton = Roact.PureComponent:extend("ToggleButton")
Typecheck.wrap(ToggleButton, script)

ToggleButton.defaultProps = {
	Disabled = false,
	Selected = false,
	Text = "",
}

function ToggleButton:init(props)
	self.onClick = function()
		local isDisabled = self.props.Disabled
		local onClick = self.props.OnClick
		if not isDisabled then
			onClick()
		end
	end
end

function ToggleButton:render()
	local anchorPoint = self.props.AnchorPoint
	local isDisabled = self.props.Disabled
	local isSelected = self.props.Selected
	local layoutOrder = self.props.LayoutOrder
	local position = self.props.Position
	local size = self.props.Size
	local text = self.props.Text
	local theme = self.props.Theme
	local zIndex = self.props.ZIndex

	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local styleModifier
	if isDisabled then
		styleModifier = StyleModifier.Disabled
	elseif isSelected then
		styleModifier = StyleModifier.Selected
	end

	return Roact.createElement(Button, {
		AnchorPoint = anchorPoint,
		LayoutOrder = layoutOrder,
		OnClick = self.onClick,
		StyleModifier = styleModifier,
		Position = position,
		Size = size,
		Style = style,
		Text = text,
		ZIndex = zIndex,
	}, {
		PointingHand = not isDisabled and Roact.createElement(HoverArea, {Cursor = "PointingHand"}) or nil,
	})
end

ContextServices.mapToProps(ToggleButton, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return ToggleButton
