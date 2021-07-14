--[[
	A button that can be selected and shows text after a Background.

	Required Props:
		string Key: The key that will be sent back to the OnClick function.
		string Text: The text to display.

	Optional Props:
		boolean Disabled: Whether or not the radio button is disabled. OnClick will not work when disabled.
		number LayoutOrder: The layout order of the frame.
		callback OnClick: paramters(string key). Fires when the button is activated and returns back the Key.
		boolean Selected: Whether or not the radio button is selected.
		Style Style: The style with which to render this component.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]
local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Button = require(Framework.UI.Button)
local TextLabel = require(Framework.UI.TextLabel)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local RadioButton = Roact.PureComponent:extend("RadioButton")
Typecheck.wrap(RadioButton, script)

local NO_WRAP = Vector2.new(1000000, 50)

RadioButton.defaultProps = {
	Disabled = false,
	Selected = false,
	OnClick = function() end,
}

function RadioButton:init()
	self.onClick = function()
		local isDisabled = self.props.Disabled
		local key = self.props.Key
		local onClick = self.props.OnClick
		if not isDisabled then
			onClick(key)
		end
	end
end

function RadioButton:render()
	local isSelected = self.props.Selected
	local isDisabled = self.props.Disabled
	local layoutOrder = self.props.LayoutOrder
	local text = self.props.Text
	local theme = self.props.Theme

	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local font = style.Font
	local textSize = style.TextSize
	local imageSize = style.ImageSize
	local padding = style.Padding or 0

	local textDimensions
	if font then
		textDimensions = TextService:GetTextSize(text, textSize, font, NO_WRAP)
	else
		textDimensions = Vector2.new()
	end

	local buttonHeight
	local buttonSize
	if imageSize then
		buttonHeight = math.max(imageSize.Y.Offset, textDimensions.Y)
		buttonSize = UDim2.new(0, textDimensions.X + imageSize.X.Offset + padding, 0, buttonHeight)
	else
		buttonSize = UDim2.new(0, textDimensions.X + padding, 0, textDimensions.Y)
	end

	local styleModifier
	if isDisabled then
		styleModifier = StyleModifier.Disabled
	elseif isSelected then
		styleModifier = StyleModifier.Selected
	end

	return Roact.createElement("TextButton", {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = buttonSize,
		Text = "",
		[Roact.Event.Activated] = self.onClick,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, style.Padding),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		RadioImage = Roact.createElement(Button, {
			LayoutOrder = 1,
			OnClick = self.onClick,
			Size = style.ImageSize,
			Style = style.BackgroundStyle,
			StyleModifier = styleModifier,
		}),

		TextLabel = Roact.createElement(TextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(0, textDimensions.X, 1, 0),
			StyleModifier = styleModifier,
			Text = text,
		}),
	})
end

ContextServices.mapToProps(RadioButton, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return RadioButton