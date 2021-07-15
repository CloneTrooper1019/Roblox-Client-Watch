--[[
	A simple row of a tree which can be hovered, disabled & selected.

	Required Props:
		any Item: The item being displayed by this row
		number Index: The index of the row to display
		number Depth: The offset of the row
		boolean Expanded: Whether the row is expanded
		any Children: The child items of this row
		callback OnToggle: Called when the toggle icon is pressed (props) -> ()
	
	Optional Props:
		any BeforeToggle: An optional component to render before the toggle. Passed the Row props and the expected LayoutOrder.
		any BeforeIcon: An optional component to render before the icon. Passed the Row props and the expected LayoutOrder.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local Typecheck = Util.Typecheck

local Dash = require(Framework.packages.Dash)
local assign = Dash.assign
local join = Dash.join

local withControl = require(Framework.Wrappers.withControl)

local UI = Framework.UI
local Image = require(UI.Image)
local Pane = require(UI.Pane)
local TextLabel = require(UI.TextLabel)

local TreeViewRow = Roact.PureComponent:extend("TreeViewRow")
Typecheck.wrap(TreeViewRow, script)

function TreeViewRow:init()
	assert(THEME_REFACTOR, "TreeViewRow not supported in Theme1, please upgrade your plugin to Theme2")
	self.onToggle = function()
		self.props.OnToggle(self.props)
	end
end

function TreeViewRow:render()
	local props = self.props
	local style = props.Stylizer
	local index = props.Index
	local item = props.Item
	local depth = props.Depth
	local text = item.text
	local icon = item.icon
	local hasChildren = #props.Children > 0
	local isExpanded = props.Expanded
	local arrowSize = style.Arrow.Size
	local beforeToggle = props.BeforeToggle
	local beforeIcon = props.BeforeIcon

	local indent = depth * style.Indent

	local padding = {
		Top = style.Padding.Top,
		Left = style.Padding.Left + indent,
		Right = style.Padding.Right,
		Bottom = style.Padding.Bottom,
	}
	return Roact.createElement(Pane, assign({
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, style.RowHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		Style = "Box",
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		BackgroundColor3 = style.Background,
		Padding = padding,
		Spacing = style.Spacing
	}, props.WrapperProps), {
		BeforeToggle = beforeToggle and Roact.createElement(beforeToggle, join(props, {
			LayoutOrder = 1,
		})) or nil,
		Toggle = hasChildren and Roact.createElement("ImageButton", {
			LayoutOrder = 2,
			Size = UDim2.new(0, arrowSize, 0, arrowSize),
			BackgroundTransparency = 1,
			Image = style.Arrow.Image,
			ImageColor3 = style.Arrow.Color,
			ImageRectSize = Vector2.new(arrowSize, arrowSize),
			ImageRectOffset = isExpanded and style.Arrow.ExpandedOffset or style.Arrow.CollapsedOffset,
			[Roact.Event.Activated] = self.onToggle
		}) or nil,
		BeforeIcon = beforeIcon and Roact.createElement(beforeIcon, join(props, {
			LayoutOrder = 3,
		})) or nil,
		LeftIcon = icon and Roact.createElement(Image, join({
			LayoutOrder = 4,
		}, icon)) or nil,
		Text = text and Roact.createElement(TextLabel, {
			TextColor = style.TextColor,
			LayoutOrder = 5,
			Text = text,
			AutomaticSize = Enum.AutomaticSize.XY,
		}) or nil,
	})
end

ContextServices.mapToProps(TreeViewRow, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
})

return withControl(TreeViewRow)
