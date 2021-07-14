--[[
	An implementation of BaseDialog that adds UILibrary Buttons to the bottom.
	To use the component, the consumer supplies an array of buttons, optionally
	defining a Style for each button if it should display differently.

	Props:
		array Buttons = An array of items used to render the buttons for this dialog.
		{
			{Key = "Cancel", Text = "SomeLocalizedTextForCancel"},
			{Key = "Save", Text = "SomeLocalizedTextForSave", Style = "Primary"},
		}
		function OnButtonClicked(key) = A callback for when the user clicked
			a button in the dialog. Accepts the Key of the button that was clicked.
		function OnClose = A callback for when the user closed the dialog by
			clicking the X in the corner of the window.

		Vector2 Size = The starting size of the dialog.
		Vector2 MinSize = The minimum size of the dialog, if it is resizable.
		bool Resizable = Whether the dialog can be resized.
		int BorderPadding = The padding to add around the edges of the dialog.
		int ButtonPadding = The padding to add between buttons.
		int ButtonHeight = The height of the buttons in the dialog, in pixels.
		int ButtonWidth = The width of each button in the dialog, in pixels.
		string Title = The title to display at the top of the window.
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local BaseDialog = require(Library.Components.BaseDialog)
local Button = require(Library.Components.Button)

local StyledDialog = Roact.PureComponent:extend("StyledDialog")

function StyledDialog:init()
	self.enabledChanged = function(enabled)
		if not enabled and self.props.OnClose then
			self.props.OnClose()
		end
	end

	self.buttonClicked = function(button)
		if self.props.OnButtonClicked then
			self.props.OnButtonClicked(button.Key)
		end
	end
end

function StyledDialog:render()
	return withTheme(function(theme)
		local props = self.props
		local title = props.Title
		local size = props.Size
		local minSize = props.MinSize
		local resizable = props.Resizable
		local borderPadding = props.BorderPadding
		local textSize = props.TextSize

		local buttons = props.Buttons
		local buttonPadding = props.ButtonPadding
		local buttonHeight = props.ButtonHeight
		local buttonWidth = props.ButtonWidth

		return Roact.createElement(BaseDialog, {
			Title = title,
			Size = size,
			MinSize = minSize,
			Resizable = resizable,
			Buttons = buttons,
			ButtonHeight = buttonHeight,
			BorderPadding = borderPadding,
			ButtonPadding = buttonPadding,

			RenderButton = function(button, index, activated)
				return Roact.createElement(Button, {
					Size = UDim2.new(0, buttonWidth, 0, buttonHeight),
					LayoutOrder = index,
					Style = button.Style,

					OnClick = activated,
					RenderContents = function(buttonTheme)
						return {
							Text = Roact.createElement("TextLabel", {
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								Font = buttonTheme.font,
								Text = button.Text,
								TextSize = textSize,
								TextColor3 = buttonTheme.textColor,
							})
						}
					end,
				})
			end,

			OnButtonClicked = self.buttonClicked,
			OnClose = props.OnClose,
		}, self.props[Roact.Children])
	end)
end

return StyledDialog
