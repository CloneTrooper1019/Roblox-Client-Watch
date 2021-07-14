--[[
	A basic hyperlink with a callback on click.
	Size is based on the text extents.

	Required Props:
		callback OnClick: A callback for when the user clicks this link.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string Text: The text to display in this link.
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		UDim2 Position: The position of this component.
		UDim2 Size: The fixed size of this component.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		number ZIndex: The render index of this component.
		Enum.TextTruncate TextTruncate: Sets text truncated.
		UDim2 Size: The size of this component.
		number LayoutOrder: The layout order of this component in a list.
		Enum.TextXAlignment TextXAlignment: The TextXAlignment of this link.
		Enum.TextYAlignment TextYAlignment: The TextYAlignment of this link.

	Style Values:
		Enum.Font Font: The font used to render the text in this link.
		number TextSize: The font size of the text in this link.
		Color3 TextColor: The color of the text and underline in this link.
]]
local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local HoverArea = require(Framework.UI.HoverArea)

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Button = require(Framework.UI.Button)

local LinkText = Roact.PureComponent:extend("LinkText")
Typecheck.wrap(LinkText, script)

function LinkText:init(props)

	assert(props.Size or (not props.TextWrapped), "Size prop is required to use the TextWrapped prop")

	if props.TextTruncate then
		assert(props.Size ~= nil and typeof(props.Size) == "UDim2", "LinkText expects a UDim2 'Size' if the 'TextTruncate' prop passed in.")
	end

	self.state = {
		StyleModifier = nil,
		AbsoluteWidth = 0,
	}

	self.mouseEnter = function()
		self:setState({
			StyleModifier = StyleModifier.Hover,
		})
	end

	self.mouseLeave = function()
		self:setState({
			StyleModifier = Roact.None,
		})
	end
end

function LinkText:render()
	local props = self.props
	local state = self.state
	local theme = props.Theme
	local styleModifier = state.StyleModifier
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local size = props.Size

	local font = style.Font
	local textSize = style.TextSize
	local textColor = style.TextColor
	local text = props.Text or ""
	local textTruncate = props.TextTruncate
	local textWrapped = props.TextWrapped
	local textXAlignment = props.TextXAlignment
	local textYAlignment = props.TextYAlignment

	local isMultiline = false
	local textDimensions
	if textTruncate then
		textDimensions = size
	else
		if font then
			if textWrapped then
				local textDimensionsExtents = TextService:GetTextSize(text, textSize, font,
					Vector2.new(state.AbsoluteWidth, math.huge))
				textDimensions = UDim2.new(size.X, UDim.new(0, textDimensionsExtents.Y))
				isMultiline = textDimensionsExtents.Y ~= TextService:GetTextSize("", textSize, font, Vector2.new())
			else
				local textExtents = TextService:GetTextSize(text, textSize, font, Vector2.new())
				textDimensions = UDim2.fromOffset(textExtents.X, textExtents.Y)
			end
		else
			textDimensions = UDim2.new()
		end
	end

	local onClick = props.OnClick
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local zIndex = props.ZIndex
	local layoutOrder = props.LayoutOrder

	local hovered = styleModifier == StyleModifier.Hover

	local enableHover = (style.EnableHover == nil) and true or style.EnableHover
	local showUnderline = (style.ShowUnderline == nil) and true or style.ShowUnderline

	return Roact.createElement(Button, {
		Style = {
			Font = font,
			TextSize = textSize,
			TextColor = textColor,
			TextTruncate = textTruncate,
			TextWrapped = textWrapped,
			TextXAlignment = textXAlignment,
			TextYAlignment = textYAlignment,
		},
		Size = textDimensions,
		Position = position,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
		Text = text,
		OnClick = onClick,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				self:setState({
					AbsoluteWidth = rbx.AbsoluteContentSize.X,
				})
			end,
		}),

		HoverArea = enableHover and Roact.createElement(HoverArea, {
			Cursor = "PointingHand",
			MouseEnter = self.mouseEnter,
			MouseLeave = self.mouseLeave,
		}),

		Underline = showUnderline and hovered and (not isMultiline) and Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = textColor,
			BorderSizePixel = 0,
		}),
	})
end

ContextServices.mapToProps(LinkText, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return LinkText
