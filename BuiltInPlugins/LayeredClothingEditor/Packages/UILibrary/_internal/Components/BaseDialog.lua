--[[
	A basic dialog with content and a set of buttons.
	Other dialogs can use this component to provide more specific implementations.
	While this component allows the creation of any arbitrary buttons, in most
	cases a StyledDialog is preferred if the normal UILibrary buttons are desired.

	Required Props:
		array<variant> Buttons = An array of items used to render
			the buttons for this dialog.
		function RenderButton(button, index, activated) = A function
			used to render a button. This function is called for each
			item in the Buttons array. It should return a Roact component
			that connects a signal to the activated parameter.

	Props:
		Vector2 Size = The starting size of the dialog.
		Vector2 MinSize = The minimum size of the dialog, if it is resizable.
		bool Resizable = Whether the dialog can be resized.
		int BorderPadding = The padding to add around the edges of the dialog.
		int ButtonPadding = The padding to add between buttons.
		int ButtonHeight = The height of the buttons in the dialog, in pixels.
		string Title = The title to display at the top of the window.

		function OnClose = A callback for when the user closed the dialog by
			clicking the X in the corner of the window.
		function OnButtonClicked(button) = A callback for when the user clicked
			a button in the dialog. Returns the button that was clicked.
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Dialog = require(Library.Components.PluginWidget.Dialog)

local BaseDialog = Roact.PureComponent:extend("BaseDialog")

function BaseDialog:init()
	self.buttonClicked = function(button)
		if self.props.OnButtonClicked then
			self.props.OnButtonClicked(button)
		end
	end
end

function BaseDialog:render()
	return withTheme(function(theme)
		local props = self.props

		local title = props.Title
		local size = props.Size
		local minSize = props.MinSize
		local resizable = props.Resizable
		local borderPadding = props.BorderPadding or 0

		local buttons = props.Buttons
		local buttonPadding = props.ButtonPadding or 0
		local buttonHeight = props.ButtonHeight or 0
		local renderButton = props.RenderButton

		assert(buttons ~= nil and type(buttons) == "table",
			"BaseDialog requires a Buttons table.")
		assert(renderButton ~= nil and type(renderButton) == "function",
			"BaseDialog requires a RenderButton function.")
		assert(buttonHeight ~= nil and type(buttonHeight) == "number",
			"BaseDialog requires a ButtonHeight value.")

		local buttonComponents = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, buttonPadding),
			}),
		}

		for index, button in ipairs(buttons) do
			table.insert(buttonComponents, renderButton(button, index, function()
				self.buttonClicked(button)
			end))
		end

		return Roact.createElement(Dialog, {
			Options = {
				Size = size,
				Resizable = resizable,
				MinSize = minSize,
				Modal = true,
				InitialEnabled = true,
			},
			Title = title,
			OnClose = props.OnClose,
		}, {
			Background = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = theme.dialog.background,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, borderPadding),
					PaddingBottom = UDim.new(0, borderPadding),
					PaddingLeft = UDim.new(0, borderPadding),
					PaddingRight = UDim.new(0, borderPadding),
				}),

				Content = Roact.createElement("Frame", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 1, -(buttonHeight + borderPadding)),
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
				}, self.props[Roact.Children]),

				Buttons = Roact.createElement("Frame", {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, buttonHeight),
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, 0),
					BackgroundTransparency = 1,
				}, buttonComponents),
			})
		})
	end)
end

return BaseDialog
