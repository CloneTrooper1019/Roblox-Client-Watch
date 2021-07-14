--[[
	A text entry that is only one line.
	Used in a RoundTextBox when Multiline is false.

	Props:
		string Text = The text to display
		string PlaceholderText = text to display when box is empty/in default state
		bool Visible = Whether to display this component
		function SetText(text) = Callback to tell parent that text has changed
		function FocusChanged(focus) = Callback to tell parent that this component has focus
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local TextEntry = Roact.PureComponent:extend("TextEntry")
local FFlagFixTextChangedFromEmptyForTextEntry = game:DefineFastFlag("FixTextChangedFromEmptyForTextEntry", false)

function TextEntry:init()
	self.textBoxRef = Roact.createRef()
	self.onTextChanged = function(rbx)
		if rbx.TextFits then
			rbx.TextXAlignment = Enum.TextXAlignment.Left
		else
			rbx.TextXAlignment = Enum.TextXAlignment.Right
		end
		if FFlagFixTextChangedFromEmptyForTextEntry then
			local processed = string.gsub(rbx.Text, "[\n\r]", " ")
			self.props.SetText(processed)
		else
			if rbx.Text ~= self.props.Text then
				local processed = string.gsub(rbx.Text, "[\n\r]", " ")
				self.props.SetText(processed)
			end
		end
	end

	self.mouseEnter = function()
		self.props.HoverChanged(true)
	end
	self.mouseLeave = function()
		self.props.HoverChanged(false)
	end
end

function TextEntry:render()
	return withTheme(function(theme)
		local textSize = self.props.TextSize
		local font = self.props.Font

		local textEntryTheme = theme.textEntry

		local size = self.props.Size and self.props.Size or UDim2.new(1, 0, 1, 0)
		local position = self.props.Position and self.props.Position or nil
		local enabled = (self.props.Enabled == nil) and true or self.props.Enabled
		local textTransparency = enabled and textEntryTheme.textTransparency.enabled or textEntryTheme.textTransparency.disabled

		return Roact.createElement("Frame", {
			Size = size,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			Text = Roact.createElement("TextBox", {
				Visible = self.props.Visible,

				Size = UDim2.new(1, 0, 1, 0),
				Position = position,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				PlaceholderText  = self.props.PlaceholderText,
				PlaceholderColor3 = self.props.TextColor3,
				ClearTextOnFocus = false,
				Font = font,
				TextSize = textSize,
				TextColor3 = self.props.TextColor3,
				Text = self.props.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = textTransparency,
				TextEditable = enabled,

				[Roact.Ref] = self.textBoxRef,

				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseLeave] = self.mouseLeave,

				[Roact.Event.Focused] = function()
					self.props.FocusChanged(true)
				end,

				[Roact.Event.FocusLost] = function()
					-- workaround because we do not disconnect events before we start unmounting host components.
					-- see https://github.com/Roblox/roact/issues/235 for more info
					if not self.textBoxRef.current then return end

					local textBox = self.textBoxRef.current
					textBox.TextXAlignment = Enum.TextXAlignment.Left
					self.props.FocusChanged(false)
				end,

				[Roact.Change.Text] = function(rbx) 
					-- workaround because we do not disconnect events before we start unmounting host components.
					-- see https://github.com/Roblox/roact/issues/235 for more info
					if not self.textBoxRef.current then return end

					self.onTextChanged(rbx)
				end
			}),
		})
	end)
end

return TextEntry
