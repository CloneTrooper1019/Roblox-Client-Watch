--[[
	TreeView<Item extends any> - Displays a hierarchical data set.

	Required Props:
		UDim2 Size: The size of the component
		table RootItems: The root items displayed in the tree view.
		callback GetChildren: This should return a list of children for a given item - GetChildren(item: Item) => Item[]
		callback RenderRow: This should return the Roact element for a given row - RenderRow(node: Row) => Roact.Element
		table Expansion: Which items should be expanded - Set<Item>

	Optional Props:
		Theme Theme: The theme supplied from mapToProps()
		Style Style: a style table supplied from props and theme:getStyle()
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		callback SortChildren: A comparator function to sort two items in the tree - SortChildren(left: Item, right: Item) => boolean
		callback GetItemKey: Return a key for an item, unique among siblings - GetItemKey(item: Item) => string
		Enum.ScrollingDirection ScrollingDirection: The direction to allow scroll in default = XY
		number LayoutOrder: LayoutOrder of the component.

	Style Values:
		table ScrollingFrame: Style values for the tree view's scrolling frame.
		Component Background: The background to render for this tree view.
		Style BackgroundStyle: The style with which to render the background.
		number Padding: The amount of padding around the scrolling frame.
]]

--[[
interface Row<Item extends any> {
	item: Item,
	index: number,
	depth: number
}
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Typecheck = require(Framework.Util).Typecheck

local UI = Framework.UI
local Container = require(UI.Container)
local Util = require(Framework.Util)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local TreeView = Roact.PureComponent:extend("TreeView")
local ScrollingFrame = require(Framework.UI.ScrollingFrame)
Typecheck.wrap(TreeView, script)

TreeView.defaultProps = {}

function TreeView:init()
	self.state = {
		rows = {}
	}
end

function TreeView:didMount()
	self:calculateRows()
end

function TreeView:didUpdate(prevProps)
	self:calculateRows(prevProps)
end

function TreeView:calculateRows(prevProps)
	if (prevProps
		and self.props.RenderRow == prevProps.RenderRow
		and self.props.RootItems == prevProps.RootItems
		and self.props.GetChildren == prevProps.GetChildren
		and self.props.GetItemKey == prevProps.GetItemKey
		and self.props.Expansion == prevProps.Expansion
	) then
		return
	end
	local rows = {}
	for _, child in ipairs(self.props.RootItems) do
		self:contributeItem(child, 0, rows)
	end
	self:setState({
		rows = rows
	})
end

function TreeView:contributeItem(item, depth, list)
	local props = self.props
	table.insert(list, {
		index = #list + 1,
		depth = depth,
		item = item,
	})
	if props.Expansion[item] then
		local children = props.GetChildren(item)
		if props.SortChildren then
			table.sort(children, props.SortChildren)
		end
		for _, child in ipairs(children) do
			self:contributeItem(child, depth + 1, list)
		end
	end
	return list
end

function TreeView:render()
	local props = self.props
	local state = self.state
	local rows = state.rows
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local children = {}
	for index, row in ipairs(rows) do
		local key = props.GetItemKey and props.GetItemKey(row.item, index) or index
		children[key] = props.RenderRow(row)
	end

	return Roact.createElement(Container, {
		Padding = style.Padding,
		Size = props.Size,
		Background = style.Background,
		BackgroundStyle = style.BackgroundStyle,
		LayoutOrder = props.LayoutOrder,
	}, {
		ScrollingFrame = Roact.createElement(ScrollingFrame, {
			Size = UDim2.fromScale(1, 1),
			Style = style.ScrollingFrame,
			ScrollingDirection = props.ScrollingDirection,
			AutoSizeCanvas = true,
			AutoSizeLayoutOptions = {
				SortOrder = Enum.SortOrder.LayoutOrder
			}
		}, children)
	})
end

ContextServices.mapToProps(TreeView, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TreeView