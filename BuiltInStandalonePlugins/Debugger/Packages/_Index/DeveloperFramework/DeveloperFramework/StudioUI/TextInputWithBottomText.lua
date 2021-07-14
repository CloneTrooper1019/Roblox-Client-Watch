--[[
	A text input with max character count error handling.

	Required Props:
		string BottomText: text that appears below the textBox.
		UDim2 Size: The size of this component.
		table TextInputProps: See TextInput for full props list

	Optional Props:
		number LayoutOrder: The layout order of this component in a list.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.

	Style Values:
		Enum.Font Font: The font used to render the text.
		number Spacing: The spacing between the text input and bottom text.
		Color3 PlaceholderTextColor: The color of the placeholder text.
		number TextSize: The font size of the text.
		Color3 TextColor: The color of the search term text.
]]
local Framework = script.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local prioritize = Util.prioritize

local MultiLineTextInput = require(Framework.UI.MultiLineTextInput)
local Pane = require(Framework.UI.Pane)
local TextInput = require(Framework.UI.TextInput)
local TextLabel = require(Framework.UI.TextLabel)

local TextInputWithBottomText = Roact.PureComponent:extend("TextInputWithBottomText")
Typecheck.wrap(TextInputWithBottomText, script)

local function getStyle(self)
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end
	return style
end

function TextInputWithBottomText:render()
	local props = self.props
	local bottomText = props.BottomText
	local layoutOrder = props.LayoutOrder
	local size = props.Size
	local textInputProps = props.TextInputProps
	local isMultiLine = textInputProps.MultiLine

	local style = getStyle(self)

	local textSize = prioritize(props.TextSize, style.TextSize, 0)
	local spacing = prioritize(props.Spacing, style.Spacing, 0)
	local textColor = prioritize(props.TextColor, style.TextColor, nil)
	local textInputStyle = prioritize(props.TextInputStyle, style.TextInputStyle, nil)

	return Roact.createElement(Pane, {
		AutomaticSize = Enum.AutomaticSize.Y,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		LayoutOrder = layoutOrder,
		Layout = Enum.FillDirection.Vertical,
		Spacing = spacing,
	}, {
		TextInput = isMultiLine and Roact.createElement(MultiLineTextInput, Cryo.Dictionary.join(textInputProps, {
			LayoutOrder = 1,
			Size = size,
			Style = textInputStyle,
			TextInputProps = Cryo.Dictionary.join(textInputProps,{
				Style = Roact.None,
			}),
		}))
		or Roact.createElement(TextInput, Cryo.Dictionary.join(textInputProps, {
			LayoutOrder = 1,
			Size = size,
			Style = textInputStyle,
		})),

		BottomText = Roact.createElement(TextLabel, {
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 2,
			Text = bottomText,
			TextColor = textColor,
			TextSize = textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
	})
end

ContextServices.mapToProps(TextInputWithBottomText, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TextInputWithBottomText
