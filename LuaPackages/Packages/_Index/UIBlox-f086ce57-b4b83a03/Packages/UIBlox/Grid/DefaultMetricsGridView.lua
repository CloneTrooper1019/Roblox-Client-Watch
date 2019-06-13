local GridRoot = script.Parent
local UIBloxRoot = GridRoot.Parent

local Roact = require(UIBloxRoot.Parent.Roact)
local t = require(UIBloxRoot.Parent.t)

local GridView = require(GridRoot.GridView)

-- It is an error to have a window height > the maximum height the grid view can
-- grow to, so we check it here.
local function validateWindowHeight(props)
	if props.windowHeight ~= nil and props.windowHeight > props.maxHeight then
		return false, ("windowHeight must be less than or equal to maxHeight\nmaxHeight: %f\nwindowHeight: %f"):format(
			props.maxHeight,
			props.windowHeight
		)
	end

	return true
end

local isGridViewProps = t.intersection(
	t.strictInterface({
		-- A function that, given the width of grid cells, returns the height of
		-- grid cells.
		getItemHeight = t.callback,
		-- A grid metrics getter function (see GridMetrics).
		getItemMetrics = t.callback,
		-- How much of the grid view is visible. This determines the size of cells
		-- in the grid.
		windowHeight = t.optional(t.numberMin(0)),
		-- A function that, given an item, returns a Roact element representing that
		-- item. The item should expect to fill its parent. Setting LayoutOrder is
		-- not necessary.
		renderItem = t.callback,
		-- The spacing between grid cells, on each axis.
		itemPadding = t.Vector2,
		-- All the items that can be displayed in the grid. renderItem should be
		-- able to use all values in this table.
		items = t.table,
		-- The maximum height the grid view is allowed to grow to.
		maxHeight = t.numberMin(0),
		-- The layout order of the grid.
		LayoutOrder = t.optional(t.integer),
	}),
	validateWindowHeight
)

local DefaultMetricsGridView = Roact.PureComponent:extend("DefaultMetricsGridView")

DefaultMetricsGridView.defaultProps = {
	maxHeight = math.huge,
}

function DefaultMetricsGridView:init()
	self.state = {
		containerWidth = 0,
	}
end

function DefaultMetricsGridView:render()
	assert(isGridViewProps(self.props))

	local itemMetrics = self.props.getItemMetrics(self.state.containerWidth, self.props.itemPadding.X)
	local itemHeight = self.props.getItemHeight(itemMetrics.itemWidth)

	local size = Vector2.new(
		math.max(0, itemMetrics.itemWidth),
		math.max(0, itemHeight)
	)

	return Roact.createElement(GridView, {
		renderItem = self.props.renderItem,
		maxHeight = self.props.maxHeight,
		itemSize = size,
		itemPadding = self.props.itemPadding,
		items = self.props.items,
		LayoutOrder = self.props.LayoutOrder,
		onWidthChanged = function(newWidth)
			self:setState({
				containerWidth = newWidth,
			})
		end,
	})
end

return DefaultMetricsGridView