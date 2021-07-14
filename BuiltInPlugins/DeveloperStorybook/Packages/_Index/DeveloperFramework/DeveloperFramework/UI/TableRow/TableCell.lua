--[[
	A simple cell of a table which can be hovered, disabled & selected.
]]
local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = Framework.UI
local Pane = require(UI.Pane)
local Tooltip = require(UI.Tooltip)
local TextLabel = require(UI.TextLabel)

local function TableCell(props)
	local value: any = props.Value
	local style = props.Style
	local width = props.Width or UDim.new(1 / #props.Columns, 0)
	local backgroundColor = ((props.RowIndex % 2) == 1) and style.BackgroundOdd or style.BackgroundEven
	local stringValue: string
	if typeof(value) == "number" and math.floor(value) ~= value then
		-- Round to 3dp for readability
		stringValue = ("%.3f"):format(value)
	else
		stringValue = tostring(value)
	end
	local tooltipText = props.Tooltip or stringValue
	local hasTooltip = tooltipText ~= nil and tooltipText ~= ""
	return Roact.createElement(Pane, {
		LayoutOrder = props.ColumnIndex,
		Padding = {
			Top = 1,
			Bottom = 1,
			Left = 5,
			Right = 5,
		},
		Style = "Box",
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 1,
		BorderColor3 = style.Border,
		Size = UDim2.new(width.Scale, width.Offset, 1, 0),
	}, {
		Text = Roact.createElement(TextLabel, {
			Text = stringValue,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		Tooltip = hasTooltip and Roact.createElement(Tooltip, {
			MaxWidth = style.Tooltip.MaxWidth,
			Text = tooltipText,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	})
end

return TableCell
