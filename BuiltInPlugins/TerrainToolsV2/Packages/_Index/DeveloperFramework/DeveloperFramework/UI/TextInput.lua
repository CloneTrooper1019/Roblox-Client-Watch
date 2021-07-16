--[[
	A single line text input box.
	It handles scrolling to the right when the text reaches the end of the visible box. That functionality can be removed from here when UISYS-276 is implemented.
	It supports a placeholder value.
	It does not handle labels, error messages or tooltips. They should be implemented by higher order wrappers.
	Descended from TextEntry in UILibrary and LabeledTextInput in TerrainTools.

	Optional Props:
		boolean Enabled: Whether the input is editable. Defaults to true.
		number LayoutOrder: The layout order of this component in a list.
		callback OnTextChanged: callback for when the text was changed - OnTextChanged(text: string)
		callback OnFocusGained: callback to tell parent that this component's focus was gained - OnFocusGained()
		callback OnFocusLost: callback to tell parent that this component's focus was lost - OnFocusLost(enterPressed: boolean)
		string PlaceholderText: Placeholder text to show when the input is empty.
		string Text: Text to populate the input with.
		Style Style: The style with which to render this component.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		boolean ShouldFocus: Set focus onto the box so that the user can start typing.
		UDim2 Position: The position of this component.
		UDim2 Size: The size of this component.
		Vector2 AnchorPoint: The anchor point of this component
		boolean MultiLine: If the TextBox is Multilined.
		boolean TextWrapped: If the Text should be wrapped to the next line.
		Enum.Font Font: The font used to render the text.
		Enum.TextYAlignment TextYAlignment: The Y Alignment of the text.
		number TextSize: The font size of the text.

	Style Values:
		Enum.Font Font: The font used to render the text.
		Color3 PlaceholderTextColor: The color of the placeholder text.
		number Padding: The padding of the text input.
		table Padding: Specific padding values for Top, Bottom, Left, and Right.
		number TextSize: The font size of the text.
		Color3 TextColor: The color of the search term text.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local prioritize = Util.prioritize
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Container = require(Framework.UI.Container)
local RoundBox = require(Framework.UI.RoundBox)
local StyleModifier = require(Framework.Util.StyleModifier)

local TextInput = Roact.PureComponent:extend("TextInput")
Typecheck.wrap(TextInput, script)

local FlagsList = Util.Flags.new({
	FFlagToolboxReplaceUILibraryComponentsPt2 = {"ToolboxReplaceUILibraryComponentsPt2"},
})

function TextInput:init()
	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		self.textBoxRef = self.props[Roact.Ref] or Roact.createRef()
		self.isHover = false
		self.isFocused = false
	else
		self.textBoxRef = Roact.createRef()
	end

	self.setStyleModifier = function()
		local modifier
		if self.isFocused then
			modifier = StyleModifier.Selected
		elseif self.isHover then
			modifier = StyleModifier.Hover
		else
			modifier = Roact.None
		end

		self:setState({
			StyleModifier = modifier
		})
	end

	self.onTextChanged = function(rbx)
		-- workaround because we do not disconnect events before we start unmounting host components.
		-- see https://github.com/Roblox/roact/issues/235 for more info
		if not self.textBoxRef.current then return end

		if (not FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2"))
			or (FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and not self.props.MultiLine)
		then
			if rbx.TextFits then
				rbx.TextXAlignment = Enum.TextXAlignment.Left
			else
				rbx.TextXAlignment = Enum.TextXAlignment.Right
			end
			if rbx.Text ~= self.props.Text then
				local processed = string.gsub(rbx.Text, "[\n\r]", " ")
				if self.props.OnTextChanged then
					self.props.OnTextChanged(processed)
				end
			end
		else
			if rbx.Text ~= self.props.Text then
				self.props.OnTextChanged(rbx.Text)
			end
		end
	end

	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		self.onFocusGained = function(rbx, pressed)
			self.isFocused = true
			self.setStyleModifier()

			if self.props.OnFocusGained then
				self.props.OnFocusGained(rbx, pressed)
			end
		end
	end

	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		self.onFocusGained = function(rbx, pressed)
			self.isFocused = true
			self.setStyleModifier()

			if self.props.OnFocusGained then
				self.props.OnFocusGained(rbx, pressed)
			end
		end
	end

	self.onFocusLost = function(rbx, enterPressed)
		-- workaround because we do not disconnect events before we start unmounting host components.
		-- see https://github.com/Roblox/roact/issues/235 for more info
		if not self.textBoxRef.current then return end

		if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
			self.isFocused = false
			self.setStyleModifier()
		end

		local textBox = self.textBoxRef.current
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		if self.props.OnFocusLost then
			self.props.OnFocusLost(enterPressed)
		end
	end

	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		self.mouseEnter = function()
			self.isHover = true
			self.setStyleModifier()
		end

		self.mouseLeave = function()
			self.isHover = false
			self.setStyleModifier()
		end
	end
end

function TextInput:didUpdate(prevProps)
	-- The ShouldFocus prop is used in preference to exposing a ref to the parent component
	-- to avoid exposing the inner TextBox to manipulation
	if self.props.ShouldFocus and not prevProps.ShouldFocus and self.textBoxRef.current then
		self.textBoxRef.current:CaptureFocus()
	end
end

function TextInput:render()
	local props = self.props

	local enabled = props.Enabled == nil and true or props.Enabled
	local layoutOrder = props.LayoutOrder or 0
	local multiLine = props.MultiLine
	local placeholderText = props.PlaceholderText
	local position = props.Position
	local size = props.Size or UDim2.new(1, 0, 1, 0)
	local text = props.Text or ""
	local textWrapped = props.TextWrapped

	local theme = props.Theme
	local style
	local font
	local textSize
	if THEME_REFACTOR then
		style = props.Stylizer
		font = prioritize(props.Font, style.Font)
		textSize = prioritize(props.TextSize, style.TextSize)
	else
		style = theme:getStyle("Framework", self)
		font = style.Font
		textSize = style.TextSize
	end

	local textColor = style.TextColor
	local placeholderTextColor = style.PlaceholderTextColor

	if not FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		self.mouseEnter = function()
			self:setState({
				StyleModifier = StyleModifier.Hover
			})
		end

		self.mouseLeave = function()
			self:setState({
				StyleModifier = Roact.None
			})
		end
	end

	local textBox = Roact.createElement("TextBox", {
		Visible = self.props.Visible,

		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,

		PlaceholderText  = placeholderText,
		PlaceholderColor3 = placeholderTextColor,
		Font = font,
		MultiLine = multiLine,
		TextSize = textSize,
		TextColor3 = textColor,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or nil,
		TextEditable = enabled,
		TextWrapped = textWrapped,

		[Roact.Ref] = self.textBoxRef,

		[Roact.Event.Focused] = FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and self.onFocusGained or self.props.OnFocusGained,
		[Roact.Event.FocusLost] = self.onFocusLost,
		[Roact.Change.Text] = self.onTextChanged,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	})

	local backgroundStyle = style.BackgroundStyle
	local padding = style.Padding

	local background
	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") then
		background = (not THEME_REFACTOR or style.useRoundBox) and RoundBox or nil
	else
		background = (not THEME_REFACTOR or props.Style == "RoundedBorder") and RoundBox or nil
	end

	return Roact.createElement(Container, {
		AnchorPoint = props.AnchorPoint,
		ClipsDescendants = true,
		Position = position,
		Padding = padding,
		Size = size,
		Background = background,
		BackgroundStyle = backgroundStyle,
		LayoutOrder = layoutOrder,
	}, {
		TextBox = textBox
	})
end

ContextServices.mapToProps(TextInput, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TextInput