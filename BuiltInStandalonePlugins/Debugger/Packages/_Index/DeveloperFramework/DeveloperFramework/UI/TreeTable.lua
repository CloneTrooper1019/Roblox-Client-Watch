--[[
	The TreeTable component displays a grid of data with expandable rows.
	NOTE - The Scroll bug is due to UISYS-769. This is only expressed because Storybook displays components in an AutomaticSize layout,
	and should not affect tables which are not in an AutomaticSize heirarchy (or once this bug is address by ui-subsystem team).

	Required Props:
		array[any] Columns: The columns of the table
		array[any] RootItems: The root items displayed in the tree table view.
		callback GetChildren: This should return a list of children for a given row - GetChildren(row: Item) => Item[]
		table Expansion: The keys of rows that should be expanded - Set<Item>
		callback OnExpansionChange: Called when an item is expanded or collapsed - (changedExpansion: Set<Item>) => void

	Optional Props:
		boolean Scroll: Whether the table should scroll vertically if there are more rows than can be displayed.
		UDim2 Size: The size of the table
		number SelectedRow: The index of the currently selected row.
		number SortIndex: The index of the current column that is being sorted.
		any Footer: A Roact fragment or element to be displayed in the footer.
		boolean ShowHeader: Whether to display the header. (defalt = true)
		boolean ShowFooter: Whether to display the footer. (default = true if the Footer prop is non-nil)
		Enum.SortDirection SortOrder: The order that the column is being sorted in.
		callback GetItemKey: Return a key for an row, unique among siblings - GetItemKey(item: Item) => string
		callback SortChildren: A comparator function to sort two rows in the tree - SortChildren(left: Item, right: Item) => boolean
		callback OnHoverRow: An optional callback called when a row is hovered over. (dataIndex: number) -> ()
		callback OnMouseLeave: An optional callback called when the mouse leaves the table bounds. () -> ()
		callback OnSelectRow: An optional callback called when a row is selected. (dataIndex: number) -> ()
		callback OnSizeChange: An optional callback called when the component size changes with number of rows that can be displayed.
		callback OnPageSizeChange: An optional callback called when the size of a page changes.
		callback OnPageChange: An optional callback called when the user changes the current page of the table. (pageindex: number) -> ()
		callback OnSortChange: An optional callback called when the user sorts a column.
		callback RowComponent: An optional component to render each row.
		any CellComponent: An optional component passed to the row component which renders individual cells.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Typecheck = require(Framework.Util).Typecheck
local ContextServices = require(Framework.ContextServices)

local Dash = require(Framework.packages.Dash)
local copy = Dash.copy
local findIndex = Dash.findIndex
local mapOne = Dash.mapOne

local sort = table.sort

local Table = require(Framework.UI.Table)
local TreeTableCell = require(script.TreeTableCell)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local TreeTable = Roact.PureComponent:extend("TreeTable")
Typecheck.wrap(TreeTable, script)

function TreeTable:init()
	assert(THEME_REFACTOR, "TreeTable not supported in Theme1, please upgrade your plugin to Theme2")
	self.onToggle = function(row)
		local newExpansion = {
			[row.item] = not self.props.Expansion[row.item] or nil,
		}
		self.props.OnExpansionChange(newExpansion)
	end
	self.onSelectRow = function(row)
		if not self.props.OnSelectionChange then
			return
		end
		local newSelection = {
			[row.item] = true,
		}
		self.props.OnSelectionChange(newSelection)
	end	
	self.getRowKey = function(row)
		if not self.props.GetItemKey then
			return nil
		end
		return self.props.GetItemKey(row.item)
	end
	self.state = {
		selectedRow = nil,
		rows = {},
		cellProps = {
			OnToggle = self.onToggle,
			Expansion = self.props.Expansion,
			CellStyle = self.props.Stylizer,
		},
	}
end

function TreeTable:didMount()
	self:calculateItems()
end

function TreeTable:didUpdate(prevProps)
	self:calculateItems(prevProps)
end

function TreeTable:calculateItems(prevProps)
	local props = self.props
	local rowsChanged = not prevProps or (
		props.SortChildren ~= prevProps.SortChildren
		or props.RootItems ~= prevProps.RootItems
		or props.GetChildren ~= prevProps.GetChildren
		or props.GetItemKey ~= prevProps.GetItemKey
		or props.Expansion ~= prevProps.Expansion
	)
	local selectionChanged = not prevProps or props.Selection ~= prevProps.Selection
	if not rowsChanged and not selectionChanged then
		return
	end
	self:setState(function(prevState)
		local nextState = {}
		if rowsChanged then
			local rows = {}
			for _, child in ipairs(props.RootItems) do
				self:contributeRow(child, 0, rows)
			end
			nextState.rows = rows
			nextState.cellProps = {
				OnToggle = self.onToggle,
				Expansion = props.Expansion,
				CellStyle = props.Stylizer,
			}
		end
		local rows = nextState.rows or prevState.rows
		local selectedItem = props.Selection and mapOne(props.Selection, function(_true, item)
			return item
		end) or nil
		if selectedItem then
			nextState.selectedRow = findIndex(rows, function(row)
				return row.item == selectedItem
			end)
		else
			nextState.selectedRow = Roact.None
		end
		return nextState
	end)
end

function TreeTable:contributeRow(item, depth, list)
	local props = self.props
	table.insert(list, {
		index = #list + 1,
		depth = depth,
		item = item,
	})
	if props.Expansion[item] then
		local children = copy(props.GetChildren(item))
		if props.SortChildren then
			sort(children, props.SortChildren)
		end
		for _, child in ipairs(children) do
			self:contributeRow(child, depth + 1, list)
		end
	end
	return list
end

function TreeTable:render()
	local props = self.props
	local state = self.state

	local cellComponent = props.CellComponent or TreeTableCell

	return Roact.createElement(Table, {
		CellProps = state.cellProps,
		Rows = state.rows,
		Columns = props.Columns,
		Size = props.Size,
		GetRowKey = props.GetItemKey and self.getRowKey or nil,
		SelectedRow = state.selectedRow,
		SortIndex = props.SortIndex,
		SortOrder = props.SortOrder,
		Scroll = props.Scroll,
		Footer = props.Footer,
		ShowFooter = props.ShowFooter,
		ShowHeader = props.ShowHeader,
		OnHoverRow = props.OnHoverRow,
		OnMouseLeave = props.OnMouseLeave,
		OnSelectRow = self.onSelectRow,
		OnSizeChange = self.onSizeChange,
		OnSortChange = props.OnSortChange,
		RowComponent = props.RowComponent,
		CellComponent = cellComponent,
	})
end

ContextServices.mapToProps(TreeTable, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
})

return TreeTable
