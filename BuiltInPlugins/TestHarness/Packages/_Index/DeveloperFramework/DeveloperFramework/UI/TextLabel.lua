--[[
	A simple TextLabel.

	Required Props:
		string Text: The text to display in this button.

	Optional Props:
		Vector2 AnchorPoint: The AnchorPoint of the component.
		UDim2 Position: The Position of the component.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder: The layout order of this component in a list.
		UDim2 Size: The size of this component.
		UDim2 Position: The position of this component.
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		Enum.TextXAlignment TextXAlignment: Sets text horizontal alignment.
		Enum.TextTruncate TextTruncate: Sets text truncated.
		boolean TextWrapped: Whether the text label should wrap.
		number ZIndex: The render index of this component.
		boolean FitWidth: Use FitTextLabel to fit to the parent width and set height automatically.
			Implies wrapping. Will cause the Size prop to be ignored.
		number FitMaxWidth: Max width in pixels to use with FitTextLabel.
		Color3 TextColor: The color of the label.
		number TextTransparency: The transparency of this text.
		Enum.AutomaticSize AutomaticSize: The automatic size of this text.
		Enum.TextTruncate TextTruncate: The text truncation of this text.
		Enum.Font Font: The font of this text.
		number TextSize: The size of this text.
		Enum.TextXAlignment TextXAlignment: The x alignment of this text.
		Enum.TextYAlignment TextYAlignment: The y alignment of this text.

	Style Values:
		Color3 TextColor: The color of the text label.
		number BackgroundTransparency: The transparency of the text label.
		number TextTransparency: The transparency of this text.
		Enum.TextXAlignment TextXAlignment: The x alignment of this text.
		Enum.TextYAlignment TextYAlignment: The y alignment of this text.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Immutable = Util.Immutable
local Typecheck = Util.Typecheck
local prioritize = Util.prioritize
local FitTextLabel = Util.FitFrame.FitTextLabel
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local TextLabel = Roact.PureComponent:extend("TextLabel")
Typecheck.wrap(TextLabel, script)

function TextLabel:render()
	local layoutOrder = self.props.LayoutOrder
	local anchorPoint = self.props.AnchorPoint
	local position = self.props.Position
	local size = self.props.Size
	local text = self.props.Text
	local theme = self.props.Theme
	local zIndex = self.props.ZIndex
	local fitWidth = self.props.FitWidth

	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local backgroundTransparency = prioritize(self.props.BackgroundTransparency, style.BackgroundTransparency, 1)
	local font = prioritize(self.props.Font, style.Font)
	local textColor = prioritize(self.props.TextColor, style.TextColor)
	local textSize = prioritize(self.props.TextSize, style.TextSize)
	local transparency = prioritize(self.props.TextTransparency, style.TextTransparency)
	local textXAlignment = prioritize(self.props.TextXAlignment, style.TextXAlignment)
	local textYAlignment = prioritize(self.props.TextYAlignment, style.TextYAlignment)
	local textTruncate = self.props.TextTruncate
	local textWrapped = self.props.TextWrapped
	local automaticSize = self.props.AutomaticSize

	local textLabelProps = {
		AnchorPoint = anchorPoint,
		AutomaticSize = automaticSize,
		Position = position,
		BackgroundTransparency = backgroundTransparency,
		Font = font,
		LayoutOrder = layoutOrder,
		Size = size,
		Text = text,
		TextColor3 = textColor,
		TextSize = textSize,
		TextTruncate = textTruncate,
		TextTransparency = transparency,
		TextWrapped = textWrapped,
		TextXAlignment = textXAlignment,
		TextYAlignment = textYAlignment,
		ZIndex = zIndex,
	}

	if fitWidth then
		local maximumWidth
		if self.props.FitMaxWidth ~= nil then
			maximumWidth = math.max(0, self.props.FitMaxWidth)
		end

		return Roact.createElement(
			FitTextLabel,
			Immutable.JoinDictionaries(
				textLabelProps,
				{
					width = FitTextLabel.Width.FitToText,
					maximumWidth = maximumWidth,
				}
			),
			self.props[Roact.Children]
		)
	else
		return Roact.createElement("TextLabel", textLabelProps, self.props[Roact.Children])
	end
end

ContextServices.mapToProps(TextLabel, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TextLabel
