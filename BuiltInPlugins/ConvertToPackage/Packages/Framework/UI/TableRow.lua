--[[
	A simple row of a table which can be hovered, disabled & selected.

	Required Props:
		array[any] Rows: The rows of data the table
		array[any] Columns: The columns of the table
		any Row: The current row data 
		number RowIndex: The index of the row to display relative to the current page

	Optional Props:
		any CellComponent: An optional component passed to the row component which renders individual cells.
		table CellProps: A table of props which are passed from the table's props to the CellComponent.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		boolean Selected: Whether the row is currently selected.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local TableCell = require(script.TableCell)

local withControl = require(Framework.Wrappers.withControl)

local Dash = require(Framework.packages.Dash)
local assign = Dash.assign
local map = Dash.map

local UI = Framework.UI
local Pane = require(UI.Pane)

local TableRow = Roact.PureComponent:extend("TableRow")

function TableRow:init()
	assert(THEME_REFACTOR, "TableRow not supported in Theme1, please upgrade your plugin to Theme2")
end

function TableRow:render()
	local props = self.props
	local style = props.Stylizer
	local row = props.Row
	local rowIndex = props.RowIndex
	local CellComponent = props.CellComponent or TableCell
	local columns = props.Columns
	local cells = map(columns, function(column, index: number)
		local key = column.Key or column.Name
		local value: any = row[key] or ""
		local tooltip: string = row[column.TooltipKey]
		return Roact.createElement(CellComponent, {
			CellProps = props.CellProps,
			Value = value,
			Tooltip = tooltip,
			Width = column.Width,
			Style = style,
			Columns = columns,
			Row = row,
			ColumnIndex = index,
			RowIndex = rowIndex,
		})
	end)
	return Roact.createElement(Pane, assign({
		Size = UDim2.new(1, 0, 0, style.RowHeight),
		Style = "Box",
		Layout = Enum.FillDirection.Horizontal,
	}, props.WrapperProps), cells)

end

ContextServices.mapToProps(TableRow, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
})

return withControl(TableRow)
