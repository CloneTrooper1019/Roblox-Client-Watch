--[[
	A dialog with a header, body, optional description, and 1 or 2 TextInputs. The TextInputs can have an optional Error text displayed under it.

	Required Props:
		table Buttons: Specific key value pairs for Accept and Cancel buttons. Default button is the first button in the table
			Example: Buttons = {{Key = "Submit", Text = "Submit"},{Key = "Cancel", Text = "Cancel"},}
		string Body: The body of text in the dialog
		callback OnClose: Callback for pressing the close button at top of dialog - OnClose(text: string)
		callback OnButtonPressed: Callback for pressing buttons in the button bar on dialog - OnButtonPressed(buttonKey: string, text: string, additionalText: string (optional))

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		boolean Enabled: Whether the widget is currently visible
		string Title: The text to display at the top of this dialog
		string Header: The header text to display
		string Description: An additional description for the TextInput in the dialog
		Vector2 Size: The minimum size for the dialog
		table TextInput: A table of props for the TextInputs in the dialog. There can be up to 2 text inputs in the dialog, and you should add a table of props for each. Please add empty tables if you don't want to set the optional props.
			Props (all optional): { Text, PlaceholderText, BottomText,}
			string Text: Text to populate the TextInput with
			string PlaceholderText: Placeholder text to show when the TextInput is empty
			string BottomText: Text to display underneath TextInput on Error

	Style Values:
		number TextSize: TextSize value for Header.
		table Height: TextInput height.
		table Size: The minimum size for the dialog X and Y values. The default is X = 500, Y = 300
		number Padding: Padding between components in dialog
		number Spacing: Spacing between borders of dialog
]]
local FFlagTextInputDialogDevFramework = game:GetFastFlag("TextInputDialogDevFramework")

local Framework = script.Parent.Parent

local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local ContextServices = require(Framework.ContextServices)

local Pane = require(Framework.UI.Pane)
local TextLabel = require(Framework.UI.TextLabel)
local TextInputWithBottomText = require(Framework.StudioUI.TextInputWithBottomText)
local StyledDialog = require(Framework.StudioUI.StyledDialog)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local Typecheck = Util.Typecheck
local LayoutOrderIterator = Util.LayoutOrderIterator

local TextInputDialog = Roact.PureComponent:extend("TextInputDialog")
Typecheck.wrap(TextInputDialog, script)

TextInputDialog.defaultProps = {
	Enabled = true,
	TextInput = {{Text = "", PlaceholderText = "", BottomText = "",},},
	Title = "",
}

function TextInputDialog:init()
	self.state = {
		text = self.props.TextInput[1].Text,
		additionalText = self.props.TextInput[2] and self.props.TextInput[2].Text or "",
	}
end

function TextInputDialog:render()
	assert(FFlagTextInputDialogDevFramework)
	local props = self.props

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local layoutOrderIterator = LayoutOrderIterator.new()

	local header = props.Header
	local body = props.Body
	local buttons = props.Buttons
	local description = props.Description
	local textInput = props.TextInput[1]
	local additionalTextInput = props.TextInput[2] or nil
	local text = self.state.text
	local additionalText = self.state.additionalText
	local title = props.Title
	local size = props.Size or Vector2.new(style.Size.X, style.Size.Y)
	local enabled = props.Enabled

	local onButtonPressed = props.OnButtonPressed
	local onClose = props.OnClose

	return Roact.createElement(StyledDialog, {
		Buttons = buttons,
		Title = title,
		MinContentSize = size,
		OnButtonPressed = function(buttonKey)
			if additionalTextInput then
				onButtonPressed(buttonKey, self.state.text, self.state.additionalText)
			else
				onButtonPressed(buttonKey, self.state.text)
			end
		end,
		OnClose = function()
			if additionalTextInput then
				onClose(self.state.text, self.state.additionalText)
			else
				onClose(self.state.text)
			end
		end,
		Modal = true,
		Resizable = false,
		Enabled = enabled,
		Style = "AcceptCancel",
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Pane = Roact.createElement(Pane, {
			Style = "Box",
			Padding = style.Padding,
			Spacing = style.Spacing,
			Layout = Enum.FillDirection.Vertical
		}, {
			Header = header and Roact.createElement(TextLabel, {
				TextSize = style.TextSize,
				Text = header,
				Style = "Semibold",
				AutomaticSize = Enum.AutomaticSize.XY,
				TextWrapped = true,
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Size = UDim2.new(1, 0, 0, 0),
			}) or nil,
			Body = Roact.createElement(TextLabel, {
				Text = body,
				Style = "Semibold",
				AutomaticSize = Enum.AutomaticSize.XY,
				TextWrapped = true,
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Size = UDim2.new(1, 0, 0, 0),
			}),
			Description = description and Roact.createElement(TextLabel, {
				Text = description,
				Style = "Normal",
				AutomaticSize = Enum.AutomaticSize.XY,
				TextWrapped = true,
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Size = UDim2.new(1, 0, 0, 0),
			}) or nil,
			TextInputWithBottomText = Roact.createElement(TextInputWithBottomText, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				BottomText = textInput.BottomText or "",
				Size = UDim2.new(1, 0, 0, style.Height.TextInputWithBottomText),
				Style = (textInput.BottomText ~= "" or textInput.BottomText ~= nil) and "Error" or nil,
				TextInputStyle = (textInput.BottomText == "" or textInput.BottomText == nil) and "RoundedBorder" or nil,
				TextInputProps = {
					Text = text,
					PlaceholderText = textInput.PlaceholderText,
					ShouldFocus = true,
					OnTextChanged = function(newText)
						self:setState({
							text = newText,
						})
					end,
				},
			}),
			TextInputWithBottomText2 = additionalTextInput and Roact.createElement(TextInputWithBottomText, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				BottomText = additionalTextInput.BottomText or "",
				Size = UDim2.new(1, 0, 0, style.Height.TextInputWithBottomText),
				Style = (additionalTextInput.BottomText ~= "" or additionalTextInput.BottomText ~= nil) and "Error" or nil,
				TextInputStyle = (additionalTextInput.BottomText == "" or additionalTextInput.BottomText == nil) and "RoundedBorder" or nil,
				TextInputProps = {
					Text = additionalText,
					PlaceholderText = additionalTextInput.PlaceholderText or "",
					OnTextChanged = function(newText)
						self:setState({
							additionalText = newText,
						})
					end,
				},
			}) or nil,
		}),
	})
end

ContextServices.mapToProps(TextInputDialog, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TextInputDialog