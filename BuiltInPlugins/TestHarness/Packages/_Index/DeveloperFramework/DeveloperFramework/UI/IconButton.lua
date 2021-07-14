--[[
	A button with an icon and optional text. Renders a hover state if supplied with
	an OnClick callback.

	Optional Props:
		AnchorPoint: The pivot point of this component's Position prop.
		OnClick: Callback for when user clicks the button. Also enables hovering.
		Disabled: Disables button onClick and hover; defaults to false.

		IconSize: Size of icon in button, defaults to 16px. Icon must be square.
		LeftIcon: String location of icon displayed on left.
		RightIcon: String location of icon displayed on right.

		BackgroundColor: Background color override.
		BackgroundStyle: Background color override; defaults to "BorderBox".
		HoverColor: Hover color override.

		Padding: Creates UIPadding instance on underlying pane; defaults to 10.
		Position: The position of this component.
		Spacing: Defines space between icons and text; defaults to 10.

		Text: TextLabel Displayed between LeftIcon and RightIcon
		TextXAlignment: Passed to TextLabel; defaults to left.
		TextYAlignment: Passed to TextLabel; defaults to center.
		TextColor: Passed to TextLabel; defaults to MainText
		DisabledTextColor: Passed to TextLabled; defaults to DimmedText

	Styles:
		Default: The pane has no background
]]

game:DefineFastFlag("FrameworkFixDisabledIconButton", false)
local FFlagFrameworkFixDisabledIconButton = game:GetFastFlag("FrameworkFixDisabledIconButton")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local prioritize = Util.prioritize
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Pane = require(Framework.UI.Pane)
local TextLabel = require(Framework.UI.TextLabel)

local IconButton = Roact.PureComponent:extend("IconButton")

IconButton.defaultProps = {
	BackgroundStyle = "BorderBox",
	Disabled = false,
	IconSize = 16,
	LayoutOrder = 0,
	Padding = 10,
	Spacing = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
}

function IconButton:init(props)
	self.state = {
		Hovering = false,
	}

	self.mouseEnter = function()
		self:setState({
			Hovering = true,
		})
	end

	self.mouseLeave = function()
		self:setState({
			Hovering = false,
		})
	end
end

function IconButton:render()
	local props = self.props
	local state = self.state
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = props.Theme:getStyle("Framework", self)
	end
	local anchorPoint = props.AnchorPoint
	local position = props.Position

	local hovering = state.Hovering

	local backgroundColor = prioritize(props.BackgroundColor, style.BackgroundColor)
	local hoverColor = prioritize(props.HoverColor, style.Hover.Background)

	local background = (props.OnClick and hovering) and hoverColor or backgroundColor
	background = props.Disabled and style.Disabled.Background or background
	local size = prioritize(props.Size, style.Size)

	local enabledTextColor = prioritize(props.TextColor, style.TextColor)
	local disabledTextColor = prioritize(props.DisabledTextColor, style.Disabled.TextColor)
	local textColor = (props.Disabled or not props.OnClick) and disabledTextColor or enabledTextColor

	local iconSize = props.IconSize
	local textBoxPadding = 2 * iconSize
	local textSize = UDim2.new(1, -textBoxPadding, 1, 0)

	return Roact.createElement("TextButton", {
		AnchorPoint = anchorPoint,
		AutomaticSize = props.AutomaticSize,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Position = position,
		Size = size,
		Text = "",

		[Roact.Event.Activated] = not props.Disabled and props.OnClick or nil,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, {
		WrappedComponent = Roact.createElement(Pane, {
			Layout = Enum.FillDirection.Horizontal,
			Padding = props.Padding,
			Spacing = props.Spacing,
			Style = props.BackgroundStyle,
			BackgroundColor = background,
		}, {
			LeftIcon = props.LeftIcon and Roact.createElement(Pane, {
				LayoutOrder = 1,
				Size = UDim2.fromOffset(iconSize, iconSize),
				Style = {
					Image = props.LeftIcon,
				}
			}),
			Text = props.Text and Roact.createElement(TextLabel, {
				Text = props.Text,
				TextColor = FFlagFrameworkFixDisabledIconButton and textColor or nil,
				Size = textSize,
				LayoutOrder = 2,
				TextXAlignment = props.TextXAlignment,
				TextYAlignment = props.TextYAlignment,
			}),
			RightIcon = props.RightIcon and Roact.createElement(Pane, {
				LayoutOrder = 3,
				Size = UDim2.fromOffset(iconSize, iconSize),
				Style = {
					Image = props.RightIcon,
				}
			}),
		})
	})
end

ContextServices.mapToProps(IconButton, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return IconButton
