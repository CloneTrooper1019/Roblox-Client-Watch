--[[
	A MultiLine text entry with a dynamically appearing scrollbar.

	Required Props:
		table TextInputProps: See TextInput for full props list

	Optional Props:
		StyleModifier BackgroundStyleModifier: The Modifier to index into the Background style with.
		integer LayoutOrder: The order this component will display in a UILayout.
		UDim2 Position: The position of this component.
		callback OnTextChanged: Callback to tell parent that text has changed
		UDim2 Size: The size of the component.
		Style Style: The style with which to render this component.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.

	Style Values:
		Component Background: The Decoration to use as this component's background.
		Style BackgroundStyle: The Style to style the Background decoration with.
		Enum.Font Font: The font used to render the text.
		table Padding: Specific padding values for Top, Bottom, Left, and Right.
		number ScrollBarOffset: The padding between the text input and scrollbar.
		number TextSize: The font size of the text.
]]

local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Typecheck = Util.Typecheck
local prioritize = Util.prioritize
local StyleModifier = Util.StyleModifier

local ScrollingFrame = require(Framework.UI.ScrollingFrame)
local TextInput = require(Framework.UI.TextInput)
local Container = require(Framework.UI.Container)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local MultiLineTextInput = Roact.PureComponent:extend("MultiLineTextInput")
Typecheck.wrap(MultiLineTextInput, script)

function MultiLineTextInput:init()
	self.frameRef = Roact.createRef()
	self.textBoxRef = Roact.createRef()
	self.textConnections = nil

	self.state = {
		canvasSize = UDim2.new(0, 0, 0, 0)
	}

	self.getTheme = function()
		if THEME_REFACTOR then
			return self.props.Stylizer
		else
			return self.props.Theme:getStyle("Framework", self)
		end
	end

	-- TODO: Get rid of function and replace with API call CLIPLAYEREX-2806 when it ships
	self.getPositionAtIndex = function(index)
		local frame = self.frameRef.current
		local textBox = self.textBoxRef.current
		if not frame or not textBox then
			return
		end
		local props = self.props
		local style = self.getTheme()
		local sizeX = frame.AbsoluteSize.x - style.ScrollBarOffset
		local font = prioritize(props.TextInputProps.Font, style.Font)
		local textSize = prioritize(props.TextInputProps.TextSize, style.TextSize)

		return TextService:GetTextSize(
			string.sub(textBox.Text, 0, index),
			textSize,
			font,
			Vector2.new(sizeX, math.huge)
		)
	end

	self.updateCanvas = function()
		local frame = self.frameRef.current
		local textBox = self.textBoxRef.current
		if not frame or not textBox then
			return
		end
		local props = self.props
		local style = self.getTheme()
		local sizeX = frame.AbsoluteSize.x - style.ScrollBarOffset
		local font = prioritize(props.TextInputProps.Font, style.Font)
		local textSize = prioritize(props.TextInputProps.TextSize, style.TextSize)

		local textDimensions = TextService:GetTextSize(
			textBox.Text,
			textSize,
			font,
			Vector2.new(sizeX, math.huge)
		)
		local textBoxSize = math.max(textDimensions.y, frame.AbsoluteSize.y)
		self:setState({
			canvasSize = UDim2.new(1, 0, 0, textBoxSize),
			canvasPosition = Vector2.new(0, self.getPositionAtIndex(textBox.CursorPosition).y - 2 * textSize)
		})
	end

	self.onTextChanged = function(text)
		self.updateCanvas()
		if self.props.OnTextChanged then
			self.props.OnTextChanged(text)
		end
	end

	self.onCanvasResize = function()
		self.updateCanvas()
	end

	self.onFocusGained = function()
		self:setState({
			StyleModifier = StyleModifier.Selected,
		})
	end

	self.onFocusLost = function()
		self:setState({
			StyleModifier = Roact.None,
		})
	end
end

function MultiLineTextInput:didMount()
	self.updateCanvas()
end

function MultiLineTextInput:render()
	local props = self.props
	local style = self.getTheme()

	local background = style.Background
	local backgroundStyle = style.BackgroundStyle
	local scrollerStyle = style.ScrollerStyle

	local backgroundStyleModifier = prioritize(props.BackgroundStyleModifier, style.BackgroundStyleModifier)
	local layoutOrder = props.LayoutOrder
	local position = props.Position
	local size = props.Size
	local textInputProps = props.TextInputProps

	local text = textInputProps.Text
	local textSize = prioritize(textInputProps.TextSize, style.TextSize)
	local font = prioritize(textInputProps.Font, style.Font)

	return Roact.createElement(Container, {
		Background = background,
		BackgroundStyle = backgroundStyle,
		BackgroundStyleModifier = backgroundStyleModifier,
		Position = position,
		Size = size,
		LayoutOrder = layoutOrder,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, style.Padding.Bottom),
			PaddingLeft = UDim.new(0, style.Padding.Left),
			PaddingRight = UDim.new(0, style.Padding.Right),
			PaddingTop = UDim.new(0, style.Padding.Top),
		}),

		ScrollingFrame = Roact.createElement(ScrollingFrame, {
			LayoutOrder = props.LayoutOrder,
			CanvasSize = self.state.canvasSize,
			CanvasPosition = self.state.canvasPosition,
			Size = UDim2.new(1, 0, 1, 0),
			Style = scrollerStyle,
			OnCanvasResize = self.onCanvasResize,
			[Roact.Ref] = self.frameRef,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingRight = UDim.new(0, style.ScrollBarOffset),
			}),

			Text = Roact.createElement(TextInput, Cryo.Dictionary.join(textInputProps, {
				Font = font,
				MultiLine = true,
				OnTextChanged = self.onTextChanged,
				OnFocusGained = self.onFocusGained,
				OnFocusLost = self.onFocusLost,
				Size = UDim2.new(1, 0, 1, 0),
				Text = text,
				TextSize = textSize,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				[Roact.Ref] = self.textBoxRef,
			})),
		})
	})
end

ContextServices.mapToProps(MultiLineTextInput, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return MultiLineTextInput