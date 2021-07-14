--[[
	A simple cell of a table which can be hovered, disabled & selected.
]]
local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local UI = Framework.UI
local Image = require(UI.Image)
local Pane = require(UI.Pane)
local Tooltip = require(UI.Tooltip)
local TextLabel = require(UI.TextLabel)

local TreeTableCell = Roact.PureComponent:extend("TreeTableCell")

function TreeTableCell:init()
	self.onToggle = function()
		local cellProps = self.props.CellProps
		cellProps.OnToggle(self.props.Row)
	end
end

function TreeTableCell:render()
	local props = self.props
	local column = props.Columns[props.ColumnIndex]
	local key = column.Key or column.Name
	local width = props.Width or UDim.new(1 / #props.Columns, 0)
	local row = props.Row
	local cellProps = props.CellProps
	local value = row.item[key]

	local text, leftIcon
	if typeof(value) == "table" then
		text = tostring(value.Value)
		leftIcon = value.LeftIcon
	else
		text = tostring(value)
	end

	local tooltipText = props.Tooltip or text
	local hasTooltip = tooltipText ~= nil and tooltipText ~= ""
	
	local style = join(props.Style, cellProps.CellStyle)
	local backgroundColor = ((props.RowIndex % 2) == 1) and style.BackgroundOdd or style.BackgroundEven
	local isExpanded = cellProps.Expansion[row.item]
	local arrowSize = style.Arrow.Size
	local indent = row.depth * style.Indent

	local isFirstRow = props.ColumnIndex == 1
	local padding = isFirstRow and {
		Top = style.CellPadding.Top,
		Left = style.CellPadding.Left + indent,
		Right = style.CellPadding.Right,
		Bottom = style.CellPadding.Bottom,
	} or style.CellPadding
	local hasChildren = isFirstRow and row.item.children and #row.item.children > 0

	return Roact.createElement(Pane, {
		Style = "Box",
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 1,
		BorderColor3 = style.Border,
		Size = UDim2.new(width.Scale, width.Offset, 1, 0),
	}, {
		Tooltip = hasTooltip and Roact.createElement(Tooltip, {
			MaxWidth = style.Tooltip.MaxWidth,
			Text = tooltipText,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Left = Roact.createElement(Pane, {
			Layout = Enum.FillDirection.Horizontal,
			LayoutOrder = props.ColumnIndex,
			Padding = padding,
			Spacing = style.CellSpacing,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.XY,
		}, {
			Toggle = hasChildren and Roact.createElement("ImageButton", {
				LayoutOrder = 1,
				Size = UDim2.new(0, arrowSize, 0, arrowSize),
				BackgroundTransparency = 1,
				Image = style.Arrow.Image,
				ImageColor3 = style.Arrow.Color,
				ImageRectSize = Vector2.new(arrowSize, arrowSize),
				ImageRectOffset = isExpanded and style.Arrow.ExpandedOffset or style.Arrow.CollapsedOffset,
				[Roact.Event.Activated] = self.onToggle
			}) or nil,
			LeftIcon = leftIcon and Roact.createElement(Image, join({
				LayoutOrder = 2,
			}, leftIcon)) or nil,
			Text = text and Roact.createElement(TextLabel, {
				LayoutOrder = 3,
				Text = text,
				AutomaticSize = Enum.AutomaticSize.XY,
			}) or nil,
		})
	})
end

return TreeTableCell
