local FFlagTextInputDialogDevFramework = game:GetFastFlag("TextInputDialogDevFramework")

local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local TextInputDialog = FFlagTextInputDialogDevFramework and require(Framework.UI.TextInputDialog) or nil
local Button = require(Framework.UI.Button)

local ExampleTextInputDialog = Roact.PureComponent:extend("ExampleTextInputDialog")

function ExampleTextInputDialog:init()
	self.state = {
		enabled = false
	}
end

function ExampleTextInputDialog:render()
	return Roact.createElement(Button, {
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 1,
		Text = FFlagTextInputDialogDevFramework and "Open TextInputDialog" or "Not quite ready. Will be released soon!",
		OnClick = function()
			self:setState({
				enabled = true
			})
		end,
	}, {
		Dialog = FFlagTextInputDialogDevFramework and Roact.createElement(TextInputDialog,
		{
			Enabled = self.state.enabled,
			Title = "Title",
			Header = "Header",
			Buttons = {
				{Key = "Submit", Text = "Submit"},
				{Key = "Cancel", Text = "Cancel"},
			},
			Body = "Body of Dialog. You could use this to inform a user about what the dialog is doing.",
			Description = "Description for the TextInput on what the user should input or whatever you want!",
			TextInput = {{PlaceholderText = "Placeholder Text",}},
			OnClose = function(text)
				print("TextInputDialog - OnClose - TextInput: ", text)
				self:setState({
					enabled = false
				})
			end,
			OnButtonPressed = function(buttonKey, text)
				print("TextInputDialog - OnButtonPressed: ", buttonKey, " - TextInput: ", text)
				self:setState({
					enabled = false
				})
			end,
		}) or nil,
	})
end

return ExampleTextInputDialog