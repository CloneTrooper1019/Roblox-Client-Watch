--[[
	The Table component displays a grid of data in rows and columns.
	Data is passed in rows, with options for scrolling and sorting.

	Required Props:
		array[any] Rows: The rows of data the table should display
		array[any] Columns: The columns of the table.

	Optional Props:
		UDim2 Size: The size of the table
		callback GetRowKey: Return a key for an item, unique among siblings - GetRowKey(item: Item) => string (default uses a row's index)
		boolean Scroll: Whether to use a scrolling frame (default = false)
		number SelectedRow: The index of the currently selected row.
		any Footer: A Roact fragment or element to be displayed in the footer.
		boolean ShowFooter: Whether to display the footer. (default = true if the Footer prop is non-nil)
		boolean ShowHeader: Whether to display the header. (defalt = true)
		number SortIndex: The index of the current column that is being sorted.
		Enum.SortDirection SortOrder: The order that the column is being sorted in.
		callback OnHoverRow: An optional callback called when a row is hovered over. (rowIndex: number) -> ()
		callback OnMouseLeave: An optional callback called when the mouse leaves the table bounds. () -> ()
		callback OnSelectRow: An optional callback called when a row is selected. (rowIndex: number) -> ()
		callback OnSizeChange: An optional callback called when the component size changes.
		callback OnSortChange: An optional callback called when the user sorts a column.
		callback RowComponent: An optional component to render each row.
		any CellComponent: An optional component passed to the row component which renders individual cells.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		table CellProps: A table of props which are passed from the table's props to the CellComponent.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Typecheck = require(Framework.Util).Typecheck
local ContextServices = require(Framework.ContextServices)

local TableRow = require(Framework.UI.TableRow)

local Dash = require(Framework.packages.Dash)
local map = Dash.map
local collect = Dash.collect

local Pane = require(Framework.UI.Pane)
local InfiniteScrollingFrame = require(Framework.UI.InfiniteScrollingFrame)
local TableHeaderCell = require(script.TableHeaderCell)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Table = Roact.PureComponent:extend("Table")
Typecheck.wrap(Table, script)

type Column = {
	Name: string,
	Key: string?,
	Width: number?,
}

function Table:init()
	assert(THEME_REFACTOR, "Table not supported in Theme1, please upgrade your plugin to Theme2")
	self:calculateRowIndices(self.props.Rows)
	self.onHoverRow = function(rowProps)
		if self.props.OnHoverRow then
			self.props.OnHoverRow(rowProps.Row, rowProps.RowIndex)
		end
	end
	self.onHoverRowEnd = function(rowProps)
		if self.props.OnHoverRowEnd then
			self.props.OnHoverRowEnd(rowProps.Row, rowProps.RowIndex)
		end
	end
	self.onSelectRow = function(rowProps)
		if self.props.OnSelectRow then
			self.props.OnSelectRow(rowProps.Row, rowProps.RowIndex)
		end
	end
	self.onRenderRow = function(row)
		-- Infintite scroller doesn't track row indices, so store this in Table
		local rowIndex = self.rowToIndex[row]
		local props = self.props
		local RowComponent = self.props.RowComponent or TableRow
		return Roact.createElement(RowComponent, {
			CellProps = self.props.CellProps,
			CellComponent = self.props.CellComponent,
			Columns = self.props.Columns,
			Rows = self.props.Rows,
			Row = row,
			RowIndex = rowIndex,
			Selected = rowIndex == props.SelectedRow,
			OnHover = self.props.OnHoverRow and self.onHoverRow,
			OnHoverEnd = self.props.OnHoverRowEnd and self.onHoverRowEnd,
			OnPress = self.props.OnSelectRow and self.onSelectRow,
		})
	end
	self.getDefaultRowKey = function(row)
		return "Row " .. (self.rowToIndex[row] or tostring(row))
	end
	self.onSizeChange = function(rbx)
		local props = self.props
		local style = props.Stylizer
		local footerHeight = props.Footer and style.FooterHeight or 0
		-- Adjustment so as not to cut of the last row
		local listPadding = 5
		local listHeight = rbx.AbsoluteSize.Y - (style.HeaderHeight + footerHeight) - listPadding
		self.props.OnSizeChange(listHeight)
	end
end

function Table:willUpdate(nextProps)
	if self.props.Rows ~= nextProps.Rows then
		self:calculateRowIndices(nextProps.Rows)
	end
end

function Table:calculateRowIndices(rows)
	self.rowToIndex = collect(rows, function(index, row)
		return row, index
	end)
end

function Table:renderHeadings()
	local props = self.props
	local style = props.Stylizer
	return map(props.Columns, function(column: Column, index: number)
		local width = column.Width or UDim.new(1 / #props.Columns, 0)
		local order = props.SortIndex == index and props.SortOrder or nil
		return Roact.createElement(TableHeaderCell, {
			Name = column.Name,
			Order = order,
			Width = width,
			ColumnIndex = index,
			Style = style,
			OnPress = self.props.OnSortChange and function()
				-- Swap to ascending or use descending
				local nextOrder = order == Enum.SortDirection.Descending and Enum.SortDirection.Ascending or Enum.SortDirection.Descending
				self.props.OnSortChange(index, nextOrder)
			end or nil
		})
	end)
end

function Table:renderScroll()
	local props = self.props
	local style = props.Stylizer
	local getItemKey = props.GetRowKey or self.getDefaultRowKey
	return Roact.createElement(InfiniteScrollingFrame, {
		AnchorLocation = UDim.new(1, 0),
		ItemIdentifier = getItemKey,
		EstimatedItemSize = style.RowHeight,
		Items = props.Rows,
		RenderItem = self.onRenderRow,
	})
end

function Table:renderRows()
	local props = self.props
	local rows = map(props.Rows, function(row: any, index: number)
		return Roact.createElement(Pane, {
			LayoutOrder = index,
			AutomaticSize = Enum.AutomaticSize.XY,
		}, {
			Row = self.onRenderRow(row)
		})
	end)
	return Roact.createFragment(rows)
end

function Table:render()
	local props = self.props
	local style = props.Stylizer
	local headings = self:renderHeadings()
	local showFooter = props.ShowFooter
	local showHeader = props.ShowHeader
	if showHeader == nil then
		showHeader = true
	end
	if showFooter == nil then
		showFooter = props.Footer ~= nil
	end
	local headerHeight = showHeader and style.HeaderHeight or 0
	local footerHeight = showFooter and style.FooterHeight or 0
	local child = props.Scroll and self:renderScroll() or self:renderRows()

	return Roact.createElement(Pane, {
		Size = props.Size,
		Layout = Enum.FillDirection.Vertical,
		Style = "BorderBox",
		Padding = 1,
		[Roact.Change.AbsoluteSize] = props.OnSizeChange and self.onSizeChange or nil,
	}, {
		Header = showHeader and Roact.createElement(Pane, {
			Layout = Enum.FillDirection.Horizontal,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, headerHeight),
			Padding = props.Scroll and style.ScrollHeaderPadding or nil,
			Style = "SubtleBox",
			BorderColor3 = style.Border,
			BorderSizePixel = 1,
		}, headings),
		List = Roact.createElement(Pane, {
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Layout = Enum.FillDirection.Vertical,
			Padding = 2,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 1, -(headerHeight + footerHeight)),
			[Roact.Event.MouseLeave] = props.OnMouseLeave,
		}, {
			Child = child
		}),
		Footer = showFooter and Roact.createElement(Pane, {
			LayoutOrder = 3,
			Style = "SubtleBox",
			BorderColor3 = style.Border,
			BorderSizePixel = 1,
			Size = UDim2.new(1, 0, 0, footerHeight),
		}, {
			Content = props.Footer,
		}),
	})
end

ContextServices.mapToProps(Table, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
})

return Table
