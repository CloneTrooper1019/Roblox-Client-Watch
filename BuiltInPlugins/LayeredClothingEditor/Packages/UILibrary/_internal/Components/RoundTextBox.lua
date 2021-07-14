--[[
	A TextBox with rounded corners that allows single-line or multiline entry,
	maximum character count, and error messages.

	Props:
		bool Active = Whether this component can be interacted with.
		int MaxLength = The maximum number of characters allowed in the TextBox.
		bool Multiline = Whether this TextBox allows a single line of text or multiple.
		int Height = The vertical size of this TextBox, in pixels.
		int WidthOffset = the horizontal offset size of this TextBox, in pixels.
		int LayoutOrder = The sort order of this component in a UIListLayout.
		int TextSize = The size of text

		boolean ErrorBorder = puts red border around text box
		string ErrorMessage = A general override message used to display an error. A non-nil ErrorMessage will border the TextBox in red.

		string Text = The text to display in the TextBox
		string PlaceholderText = text to display when TextBox is empty/in default state
		boolean ShowToolTip = do we want to show anything beneath the rounded text box (defaults to true)
		boolean ShowErrors = do we want to show any error text beneath the rounded text box, or change the border to indicate an error (defaults to true)
		function SetText(text) = Callback to tell parent that text has changed
		function FocusChanged(focused) = Callback when this TextBox is focused.
		function HoverChanged(hovering) = Callback when the mouse enters or leaves this TextBox.
]]

local DEFAULT_HEIGHT = 42
local PADDING = UDim.new(0, 10)

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local TextEntry = require(Library.Components.TextEntry)
local MultilineTextEntry = require(Library.Components.MultilineTextEntry)

local RoundTextBox = Roact.PureComponent:extend("RoundTextBox")

function RoundTextBox:init()
	self.state = {
		Focused = false,
	}

	self.focusChanged = function(focused)
		if self.props.Active then
			if self.props.FocusChanged then
				self.props.FocusChanged(focused)
			end
			self:setState({
				Focused = focused,
			})
		end
	end

	self.mouseHoverChanged = function(hovering)
		if self.props.Active then
			if self.state.Focused and self.props.HoverChanged then
				self.props.HoverChanged(hovering)
			end
		end
	end
end

function RoundTextBox:render()
	return withTheme(function(theme)
		local active = self.props.Active
		local focused = self.state.Focused
		local multiline = self.props.Multiline
		local textLength = utf8.len(self.props.Text)
		local pastMaxLength = self.props.MaxLength and textLength > self.props.MaxLength
		local errorState = self.props.ErrorMessage
			or pastMaxLength

		errorState = errorState or self.props.ErrorBorder

		local size = self.props.Size or UDim2.new(1, self.props.WidthOffset or 0, 0, self.props.Height or DEFAULT_HEIGHT)

		local backgroundProps = {
			-- Necessary to make the rounded background
			BackgroundTransparency = 1,
			Image = theme.roundFrame.backgroundImage,
			ImageTransparency = 0,
			ImageColor3 = active and theme.textBox.background or theme.textBox.disabled,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = theme.roundFrame.slice,

			Position = UDim2.new(0, 0, 0, 0),
			Size = size,

			LayoutOrder = self.props.LayoutOrder or 1,
		}

		local showToolTip = true
		if nil ~= self.props.ShowToolTip then
			showToolTip = self.props.ShowToolTip
		end

		local tooltipText
		if active then
			if showToolTip then
				if errorState and self.props.ErrorMessage then
					tooltipText = self.props.ErrorMessage
				else
					tooltipText = textLength .. "/" .. self.props.MaxLength
				end
			else
				tooltipText = ""
			end
		else
			tooltipText = ""
		end

		local borderColor
		if active then
			if errorState then
				borderColor = theme.textBox.error
			elseif focused then
				borderColor = theme.textBox.borderHover
			else
				borderColor = theme.textBox.borderDefault
			end
		else
			borderColor = theme.textBox.borderDefault
		end

		local textEntryProps = {
			Visible = self.props.Active,
			Text = self.props.Text,
			PlaceholderText = self.props.PlaceholderText,
			FocusChanged = self.focusChanged,
			HoverChanged = self.mouseHoverChanged,
			SetText = self.props.SetText,
			TextColor3 = theme.textBox.text,
			Font = theme.textBox.font,
			TextSize = self.props.TextSize,
		}

		local textEntry
		if multiline then
			textEntry = Roact.createElement(MultilineTextEntry, textEntryProps)
		else
			textEntry = Roact.createElement(TextEntry, textEntryProps)
		end

		return Roact.createElement("ImageLabel", backgroundProps, {
			Tooltip = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 2, 1, 2),
				Size = UDim2.new(1, 0, 0, 10),

				Font = Enum.Font.SourceSans,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = (active and errorState and theme.textBox.error) or theme.textBox.tooltip,
				Text = tooltipText,
				Visible = showToolTip
			}),

			Border = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = theme.roundFrame.borderImage,
				ImageColor3 = borderColor,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = theme.roundFrame.slice,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = PADDING,
					PaddingRight = PADDING,
					PaddingTop = PADDING,
					PaddingBottom = PADDING,
				}),
				Text = textEntry,
			}),
		})
	end)
end

return RoundTextBox
