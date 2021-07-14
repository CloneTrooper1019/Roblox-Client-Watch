--[[
	A multiline text entry with a dynmically appearing scrollbar.
	Used in a RoundTextBox when Multiline is true.

	Props:
		string Text = The text to display
		bool Visible = Whether to display this component
		int TextSize = The size of text
		function SetText(text) = Callback to tell parent that text has changed
		function FocusChanged(focus) = Callback to tell parent that this component has focus
		function HoverChanged(hovered) = Callback when the mouse enters or leaves this component.
]]

local TextService = game:GetService("TextService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local StyledScrollingFrame = require(Library.Components.StyledScrollingFrame)

local SCROLL_BAR_OUTSET = 9

local MultilineTextEntry = Roact.PureComponent:extend("MultilineTextEntry")

function MultilineTextEntry:init()
	self.frameRef = Roact.createRef()
	self.textBoxRef = Roact.createRef()
	self.textConnections = nil

	-- TODO: Get rid of function and replace with API call CLIPLAYEREX-2806 when it ships
	self.getPositionAtIndex = function(index)
		local frame = self.frameRef.current
		local sizeX = frame.AbsoluteSize.x - SCROLL_BAR_OUTSET
		local textSize = TextService:GetTextSize(
			string.sub(self.props.Text, 0, index),
			self.props.TextSize,
			Enum.Font.SourceSans,
			Vector2.new(sizeX, math.huge)
		)
		return textSize
	end 

	self.updateCanvas = function()
		local frame = self.frameRef.current
		local sizeX = frame.AbsoluteSize.x - SCROLL_BAR_OUTSET
		local textBox = self.textBoxRef.current
		local textSize = TextService:GetTextSize(
			self.props.Text,
			self.props.TextSize,
			Enum.Font.SourceSans,
			Vector2.new(sizeX, math.huge)
		)
		frame.CanvasSize = UDim2.new(0, 0, 0, textSize.y)
		frame.CanvasPosition = Vector2.new(0, self.getPositionAtIndex(textBox.CursorPosition).y - 2 * self.props.TextSize)
	end

	self.textChanged = function(rbx)
		if rbx.Text ~= self.props.Text then
			self.props.SetText(rbx.Text)
		end
	end

	self.mouseEnter = function()
		self.props.HoverChanged(true)
	end
	self.mouseLeave = function()
		self.props.HoverChanged(false)
	end
end

function MultilineTextEntry:didMount()
	local textBox = self.textBoxRef.current
	local frame = self.frameRef.current
	self.textConnections = {
		textBox:GetPropertyChangedSignal("Text"):connect(self.updateCanvas),
		frame:GetPropertyChangedSignal("AbsoluteSize"):connect(self.updateCanvas),
	}
	self.updateCanvas()
end

function MultilineTextEntry:willUnmount()
	for _, connection in ipairs(self.textConnections) do
		connection:Disconnect()
	end
	self.textConnections = nil
end

function MultilineTextEntry:render()
	local visible = self.props.Visible
	local text = self.props.Text
	local textColor = self.props.TextColor3
	local textSize = self.props.TextSize
	local font = self.props.Font


	return Roact.createElement(StyledScrollingFrame, {
		Size = UDim2.new(1, SCROLL_BAR_OUTSET, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ShowBackground = false,

		[Roact.Ref] = self.frameRef,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingRight = UDim.new(0, SCROLL_BAR_OUTSET),
		}),

		Text = Roact.createElement("TextBox", {
			Visible = visible,
			MultiLine = true,
			TextWrapped = true,

			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			ClearTextOnFocus = false,
			Font = font,
			TextSize = textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = textColor,
			Text = text,

			[Roact.Event.Focused] = function()
				self.props.FocusChanged(true)
			end,

			[Roact.Event.FocusLost] = function()
				self.props.FocusChanged(false)
			end,

			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,

			[Roact.Change.Text] = self.textChanged,

			[Roact.Ref] = self.textBoxRef,
		}),
	})
end

return MultilineTextEntry
