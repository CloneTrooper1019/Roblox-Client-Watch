--[[
	A simple header cell of a table which can be sorted
]]
local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Dash = require(Framework.packages.Dash)
local assign = Dash.assign

local UI = Framework.UI
local Pane = require(UI.Pane)
local TextLabel = require(UI.TextLabel)
local Image = require(UI.Image)
local Tooltip = require(UI.Tooltip)

local withControl = require(Framework.Wrappers.withControl)

local TableHeaderCell = Roact.PureComponent:extend("TableHeaderCell")

function TableHeaderCell:render()
	local props = self.props
	local name = props.Name
	local order = props.Order
	local width = props.Width
	local index = props.ColumnIndex
	local style = props.Style
	local hasSort = props.OnPress ~= nil
	return Roact.createElement(Pane, assign({
		LayoutOrder = index,
		BorderColor3 = style.Border,
		BorderSizePixel = 1,
		Padding = style.HeaderCellPadding,
		Style = "SubtleBox",
		StyleModifier = hasSort and props.StyleModifier or nil,
		Size = UDim2.new(width.Scale, width.Offset, 1, 0),
	}, props.WrapperProps), {
		Text = Roact.createElement(TextLabel, {
			Text = name,
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
		Icon = order and Roact.createElement(Image, {
			ImageColor3 = style.IconColor,
			Image = "rbxasset://textures/DeveloperFramework/Table/sort_arrow.png",
			Size = UDim2.fromOffset(6, 8),
			Position = UDim2.new(1, -10, 0, 8),
			Rotation = order == Enum.SortDirection.Descending and -90 or 90,
			AnchorPoint = Vector2.new(1, 0),
		}),
		Tooltip = Roact.createElement(Tooltip, {
			Text = name,
		}),
	})
end

return withControl(TableHeaderCell)
