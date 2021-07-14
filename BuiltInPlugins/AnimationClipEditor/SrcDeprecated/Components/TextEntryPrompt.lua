--[[
	Shows a prompt which allows the user to enter arbitrary text.

	Props:
		UDim2 Size = The size of the center popup frame.
		string PromptText = The text to display above the prompt.
		string InputText = Text to display next to the input box.
		string NoticeText = Text to display beneath the input box.
		string Text = Initial text to display in the prompt.
		array Buttons = An array of items used to render the buttons for this prompt.
		{
			{Key = false, Text = "SomeLocalizedTextForCancel"},
			{Key = true, Text = "SomeLocalizedTextForSave", Style = "Primary"},
		}

		function OnTextSubmitted(string text) = A callback for when the user
			has entered text and pressed the Ok button.
		function OnButtonClicked(string button) = A callback for when the user
			clicks a button that has a string key (not for text submitting)
		function OnClose = A callback for when the user closed the prompt.
]]

local TextService = game:GetService("TextService")

local HORIZONTAL_PADDING = 8
local VERTICAL_PADDING = 8
local HORIZONTAL_SIZE = 380
local WRAP_SIZE = Vector2.new(340, 100000)

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local StringUtils = require(Plugin.SrcDeprecated.Util.StringUtils)

local Theme = require(Plugin.SrcDeprecated.Context.Theme)
local withTheme = Theme.withTheme

local FocusedPrompt = require(Plugin.SrcDeprecated.Components.EditEventsDialog.FocusedPrompt)
local TextBox = require(Plugin.SrcDeprecated.Components.TextBox)

local TextEntryPrompt = Roact.PureComponent:extend("TextEntryPrompt")

function TextEntryPrompt:init(initialProps)
	self.state = {
		currentText = initialProps.Text or "",
	}

	self.setCurrentText = function(text)
		self:setState({
			currentText = text,
		})
	end

	self.onFocusChanged = function(rbx, focused, submitted)
		if not focused then
			local text = rbx.Text
			local result
			if submitted and text ~= "" then
				result = self.props.OnTextSubmitted(text)
			end
			if result == true then
				self.onClose()
			else
				self.setCurrentText(text)
			end
		end
	end

	self.onClose = function()
		if self.props.OnClose then
			self.props.OnClose()
		end
	end
end

function TextEntryPrompt:render()
	return withTheme(function(theme)
		local dialogTheme = theme.dialogTheme

		local props = self.props
		local state = self.state
		local promptText = props.PromptText
		local inputText = props.InputText
		local noticeText = props.NoticeText
		local hasError = props.HasError
		local buttons = props.Buttons
		local onButtonClicked = props.OnButtonClicked
		local onTextSubmitted = props.OnTextSubmitted

		local currentText = state.currentText

		local inputTextWidth = inputText
			and StringUtils.getTextWidth(inputText, dialogTheme.textSize, theme.font) or 0
		local noticeTextHeight = noticeText
			and TextService:GetTextSize(noticeText, dialogTheme.subTextSize, theme.font, WRAP_SIZE).Y or 0

		local maxHeight = Constants.PROMPT_VERTICAL_PADDING * 3
			+ VERTICAL_PADDING * 2
			+ Constants.TRACK_HEIGHT * 2
			+ noticeTextHeight
			+ Constants.PROMPT_BUTTON_SIZE.Y

		return Roact.createElement(FocusedPrompt, {
			Size = UDim2.new(0, HORIZONTAL_SIZE, 0, maxHeight),
			Buttons = buttons,
			OnButtonClicked = function(button)
				if type(button) == "string" and onButtonClicked then
					onButtonClicked(button)
				else
					if button then
						if currentText ~= "" then
							local result = onTextSubmitted(currentText)
							if result ~= false then
								self.onClose()
							end
						end
					else
						self.onClose()
					end
				end
			end,
			OnClose = self.onClose,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, VERTICAL_PADDING),
			}),

			PromptText = promptText and Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, Constants.TRACK_HEIGHT),
				BackgroundTransparency = 1,
				TextSize = dialogTheme.textSize,
				TextColor3 = dialogTheme.textColor,
				Font = theme.font,
				Text = promptText,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 1,
			}),

			Center = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, Constants.TRACK_HEIGHT),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, HORIZONTAL_PADDING),
				}),

				InputText = inputText and Roact.createElement("TextLabel", {
					LayoutOrder = -1,
					Size = UDim2.new(0, inputTextWidth, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = inputText,
					TextSize = dialogTheme.textSize,
					TextColor3 = dialogTheme.textColor,
					Font = theme.font,
				}),

				TextBox = Roact.createElement(TextBox, {
					Size = UDim2.new(1, (inputText and -inputTextWidth - HORIZONTAL_PADDING) or 0, 1, 0),
					ClearTextOnFocus = false,
					CaptureFocus = true,
					FocusChanged = self.onFocusChanged,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = currentText,
				}),
			}),

			NoticeText = noticeText and Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, noticeTextHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = noticeText,
				TextSize = dialogTheme.subTextSize,
				TextColor3 = hasError and dialogTheme.errorTextColor or dialogTheme.subTextColor,
				TextWrapped = true,
				Font = theme.font,
			}),
		})
	end)
end

return TextEntryPrompt