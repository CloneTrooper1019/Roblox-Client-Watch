local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local PaginatedTable = UI.PaginatedTable

local Dash = require(Framework.packages.Dash)
local slice = Dash.slice

local insert = table.insert
local sort = table.sort

local ControlledTable = Roact.PureComponent:extend("ControlledTable")

local exampleData = {}
for i = 1, 23 do
	insert(exampleData, {
		Name = "Row " .. i,
		Count = math.floor(math.random() * 100),
		Size = (math.floor(math.random() * 100) * 10) .. "px",
	})
end

function ControlledTable:init()
	self.state = {
		sortIndex = nil,
		sortOrder = nil,
		pageIndex = 1,
		pageSize = 1,
		rows = self:getPageRows(1, 1),
		selectedRow = nil,
	}
	self.onSortChange = function(index: number, order: Enum.SortDirection)
		local columns = {"Name", "Count", "Size"}
		sort(exampleData, function(a, b)
			local column = columns[index]
			if order == Enum.SortDirection.Descending then
				return a[column] < b[column]
			else
				return a[column] > b[column]
			end
		end)
		self:setState({
			sortIndex = index,
			sortOrder = order,
			rows = self:getPageRows(self.state.pageIndex, self.state.pageSize),
		})
	end
	self.onPageChange = function(pageIndex: number)
		self:setState({
			pageIndex = pageIndex,
			rows = self:getPageRows(pageIndex, self.state.pageSize),
		})
	end
	self.onPageSizeChange = function(pageSize: number)
		self:setState({
			pageSize = pageSize,
			rows = self:getPageRows(self.state.pageIndex, pageSize),
		})
	end
	self.onSelectRow = function(_row, index: number)
		self:setState({
			selectedRow = index + (self.state.pageIndex - 1) * self.state.pageSize,
		})
	end
end

function ControlledTable:getPageRows(pageIndex: number, pageSize: number)
	local start = (pageIndex - 1) * pageSize + 1
	return slice(exampleData, start, start + pageSize - 1)
end

function ControlledTable:render()
	local state = self.state
	local selectedRow = nil
	if state.selectedRow then
		selectedRow = state.selectedRow - (self.state.pageIndex - 1) * self.state.pageSize
	end
	return Roact.createElement(PaginatedTable, {
		Size = UDim2.new(1, 0, 0, 200),
		SortIndex = state.sortIndex,
		SortOrder = state.sortOrder,
		PageIndex = state.pageIndex,
		PageSize = state.pageSize,
		PageCount = math.ceil(#exampleData / state.pageSize),
		OnPageSizeChange = self.onPageSizeChange,
		OnPageChange = self.onPageChange,
		OnSortChange = self.onSortChange,
		SelectedRow = selectedRow,
		OnSelectRow = self.onSelectRow,
		Columns = {
			{
				Name = "Name",
			}, {
				Name = "Count",
			}, {
				Name = "Size",
			},
		},
		Rows = state.rows,
	})
end

return {
	stories = {
		{
			name = "Pagination",
			story = Roact.createElement(ControlledTable)
		},
	}
}
