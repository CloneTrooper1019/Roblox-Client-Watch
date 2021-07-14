--[[
	Displays a heirarchical data set.

	For these notes, assume that :
		- DataNode = the type of the data you have passed into the TreeView

	Props:
	(required)
		dataTree : (DataNode) the first element in some heirarchical data set
		getChildren : (function<list<DataNode>>(DataNode)) gets a list of the node's children
		renderElement : (function<RoactElement>(table)) renders the current element given a table of props

	(optional)
		sortChildren : (function<bool>(DataNode, DataNode)) a comparator function passed to table.sort()
		onSelectionChanged : (function<void>(list<DataNode>)) a callback for observing when items are selected
		expandAll: (bool) a check to determine if the entire tree should be initially expanded.
		expandRoot: (bool) a check to determine if the root of the tree should be initially expanded.
		createFlatList: (bool) a check to determine if a flat list or node/child structure should be used.

	Elements rendered by the TreeView are given the following props :
		-- data information
		element : (DataNode)
		parent : (DataNode)

		-- styling information
		rowIndex : (int) the current row of the element
		indent : (int) the current depth of the element
		canExpand : (bool) true if the element contains children
		isExpanded : (bool) true if the element is currently showing its children
		isSelected : (bool) true if the element has been selected,

		-- function callbacks
		toggleExpanded : (function<void>()) a function that tells the treeview to expand or collapse this row
		toggleSelected : (function<void>(bool)) a function that tells the treeview to select this row
]]
local FFlagStudioFixTreeViewForSquish = settings():GetFFlag("StudioFixTreeViewForSquish")

local Library = script.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local TreeView = Roact.PureComponent:extend("TreeView")

function TreeView:init()
	assert(self.props.dataTree ~= nil, "TreeView expected a dataTree, but none was provided")
	assert(type(self.props.getChildren) == "function", "TreeView expected getChildren() to be defined")
	if self.props.sortChildren then
		assert(type(self.props.sortChildren) == "function", "TreeView expected sortChildren()")
	end

	local dataTreeRoot = self.props.dataTree
	local getChildrenFunc = self.props.getChildren
	local sortChildrenFunc = self.props.sortChildren
	local expandAll = self.props.expandAll
	local expandRoot = self.props.expandRoot

	self.layoutRef = Roact.createRef()
	self.contentRef = Roact.createRef()
	self.scrollbarResizeSignalToken = nil

	self.previousNodesArray = {}
	self.nodesArray = {}

	self.state = {
		expandedItems = {},
		selectedItems = {},
	}

	--[[
		resizeScrollContent : a callback for when the content in the treeview resizes. Ensures that all content can be seen
	]]
	self.resizeScrollContent = function()
		if not FFlagStudioFixTreeViewForSquish then
			return
		end

		-- keep the canvas size equal to the size of the content in it
		local absoluteContentSize = self.layoutRef.current.AbsoluteContentSize
		self.contentRef.current.CanvasSize = UDim2.new(0, absoluteContentSize.X, 0, absoluteContentSize.Y)
	end

	--[[
		onTreeUpdated: fires a callback (if provided) for whenever the tree is created/updated. Provides the nodes of the tree
		in a list format.
	]]
	self.onTreeUpdated = function()
		local function treeChanged()
			if #self.previousNodesArray ~= #self.nodesArray then
				return true
			end

			for index, node in ipairs(self.previousNodesArray) do
				if self.nodesArray[index] ~= node then
					return true
				end
			end

			return false
		end
		if self.props.onTreeUpdated and treeChanged() then
			self.props.onTreeUpdated(self.nodesArray)
		end
	end

	--[[
		toggleStateValue : a helper function for changing state values.

		Since Roact only does partial merges of keys, this function is to help ensure that keys get removed
		when they are assigned nil.

		Args :
			tableName : (string) a table key defined in self.state
			element : (DataNode)
			copyOldState : (boolean) when true, preserves the old state. When false, removes old state entirely
	]]
	self.toggleStateValue = function(tableName, element, copyOldState)
		assert(tableName ~= nil, "Expected a table name, but found none")
		assert(self.state[tableName] ~= nil, string.format("%s does not exist in the state table", tostring(tableName)))
		assert(element ~= nil, string.format("Expected an element to add to %s but found none", tableName))
		assert(type(copyOldState) == "boolean", "Expected copyOldState to be a boolean")

		local newValue = true
		if self.state[tableName][element] then
			newValue = nil
		end

		-- copy the old table and update with the new value
		local newState = {
			[element] = newValue
		}
		if copyOldState then
			for k, v in pairs(self.state[tableName]) do
				if k ~= element then
					newState[k] = v
				end
			end
		end

		self:setState({
			[tableName] = newState
		})

		return newState
	end

	self.toggleExpandedElement = function(element)
		return function()
			if element == nil then
				return
			end

			self.toggleStateValue("expandedItems", element, true)
		end
	end

	self.toggleSelectedElement = function(element)
		-- shouldSelectAlso : (bool) if true, does not clear the previous selection
		return function(shouldSelectAlso)
			if shouldSelectAlso == nil then
				shouldSelectAlso = false
			end
			assert(type(shouldSelectAlso) == "boolean", "Expected shouldSelectAlso to be a boolean")

			local onSelectionChanged = self.props.onSelectionChanged
			local newState = self.toggleStateValue("selectedItems", element, shouldSelectAlso)

			if onSelectionChanged then
				-- return a list of selected elements
				local selectedData = {}
				for k, isSelected in pairs(newState) do
					if isSelected then
						table.insert(selectedData, k)
					end
				end
				onSelectionChanged(selectedData)
			end
		end
	end

	--[[
		createNode : provides a bunch of props to the consumer's renderElement callback

		Args :
			element : (DataNode)
			parent : (DataNode)
			rowIndex : (int) the current row of the element
			indent : (int) the current depth of the element
	]]
	-- Remove with FFlagStudioFixTreeViewForSquish
	self.DEPRECATED_createNode = function(element, parent, rowIndex, indent)
		local expandedItems = self.state.expandedItems
		local selectedItems = self.state.selectedItems
		local renderElement = self.props.renderElement
		local getChildren = self.props.getChildren

		local canExpand = next(getChildren(element)) ~= nil

		local props = {
			-- data information
			element = element,
			parent = parent,

			-- styling information
			rowIndex = rowIndex,
			indent = indent,
			canExpand = canExpand,
			isExpanded = expandedItems[element] == true,
			isSelected = selectedItems[element] == true,

			-- function callbacks
			toggleExpanded = self.toggleExpandedElement(canExpand and element or nil),
			toggleSelected = self.toggleSelectedElement(element),
		}

		return renderElement(props)
	end

	self.createNode = function(element, rowIndex, indent, children)
		local expandedItems = self.state.expandedItems
		local selectedItems = self.state.selectedItems
		local renderElement = self.props.renderElement
		local getChildren = self.props.getChildren

		local canExpand = next(getChildren(element)) ~= nil

		local props = {
			-- data information
			element = element,

			-- styling information
			rowIndex = rowIndex,
			indent = indent,
			canExpand = canExpand,
			isExpanded = expandedItems[element] == true,
			isSelected = selectedItems[element] == true,

			-- function callbacks
			toggleExpanded = self.toggleExpandedElement(canExpand and element or nil),
			toggleSelected = self.toggleSelectedElement(element),

			children = children,
		}

		return renderElement(props)
	end

	--[[
		traverseDepthFirst : visits all of the children in a tree structure, assuming they have been expanded

		Args:
			parent : (DataNode) the element to search inside for children
			depth : (int) a counter for indenting purposes
			handlers : (table) all of the callbacks to properly traverse the tree
			 - onNodeVisited : (function<void>(DataNode, int, DataNode))
			 - decideShouldContinue : (function<bool>(DataNode, int, DataNode)) decides if it should continue
			 - getChildrenOfElement : (function<list<DataNode>>(DataNode)) gets a list of children from a parent
			 - sortChildren : (optional, function<bool>(DataNode, DataNode) a comparator function to sort the children
	]]

	-- Remove with FFlagStudioFixTreeViewForSquish
	self.DEPRECATED_traverseDepthFirst = function(parent, depth, handlers)
		local children = handlers.getChildrenOfElement(parent)

		if handlers.sortChildren then
			table.sort(children, handlers.sortChildren)
		end

		for _, child in pairs(children) do
			-- alert any listeners that we've visited this node
			handlers.onNodeVisited(child, depth + 1, parent)

			-- check if there are any children of this node we should traverse
			local shouldContinue = handlers.decideShouldContinue(child, depth + 1, parent)
			if shouldContinue then
				self.DEPRECATED_traverseDepthFirst(child, depth + 1, handlers)
			end
		end
	end

	self.traverseDepthFirst = function(current, depth, handlers)
		if not handlers.decideShouldContinue(current) then
			return handlers.onNodeVisited(current, depth, {})
		end

		local children = handlers.getChildrenOfElement(current)

		local childComponents = {}

		local createFlatList
		if self.props.createFlatList == nil then
			createFlatList = true
		else
			createFlatList = self.props.createFlatList
		end

		if handlers.sortChildren then
			table.sort(children, handlers.sortChildren)
		end

		if createFlatList then
			handlers.onNodeVisited(current, depth, {})
			for _, child in pairs(children) do
				self.traverseDepthFirst(child, depth + 1, handlers)
			end
		else
			for _, child in pairs(children) do
				local childComponent = self.traverseDepthFirst(child, depth + 1, handlers)
				table.insert(childComponents, childComponent)
			end

			return handlers.onNodeVisited(current, depth, childComponents)
		end
	end
	--[[
		getVisibleNodes : returns a map of the elements to render into the tree, including the root
	]]
	self.getVisibleNodes = function()
		self.previousNodesArray = self.nodesArray
		self.nodesArray = {}

		local expandedItems = self.state.expandedItems

		local root = self.props.dataTree
		local getChildren = self.props.getChildren
		local sortChildren = self.props.sortChildren
		local createFlatList
		if self.props.createFlatList == nil then
			createFlatList = true
		else
			createFlatList = self.props.createFlatList
		end

		local numNodes = 1
		local treeNodes
		if not FFlagStudioFixTreeViewForSquish then
			treeNodes = {
				Root = self.DEPRECATED_createNode(root, nil, 0, 0),
			}
		else
			treeNodes = {}
		end

		if expandedItems[root] then
			if FFlagStudioFixTreeViewForSquish then
				treeNodes.Root = self.traverseDepthFirst(root, 0, {
					-- upon visiting a node, add it to the map of elements to display
					onNodeVisited = function(child, depth, children)
						local node = self.createNode(child, numNodes, depth, children)

						if createFlatList then
							if node then
								local nodeName = string.format("Node-%d", numNodes)
								treeNodes[nodeName] = node
								numNodes = numNodes + 1
							end

							table.insert(self.nodesArray, child)
						else
							numNodes = numNodes + 1
							return node
						end
					end,

					-- when deciding whether to continue traversing the child elements, check if it is expanded
					decideShouldContinue = function(child)
						return expandedItems[child] == true
					end,

					-- allow the consumer to figure out how to get the children of each element
					getChildrenOfElement = getChildren,
					sortChildren = sortChildren })
			else
				self.DEPRECATED_traverseDepthFirst(root, 0, {
					-- upon visiting a node, add it to the map of elements to display
					onNodeVisited = function(child, depth, parent)
						local nodeName = string.format("Node-%d", numNodes)
						treeNodes[nodeName] = self.DEPRECATED_createNode(child, parent, numNodes, depth)

						numNodes = numNodes + 1
						table.insert(self.nodesArray, child)
					end,

					-- when deciding whether to continue traversing the child elements, check if it is expanded
					decideShouldContinue = function(child, depth, parent)
						return expandedItems[child] == true
					end,

					-- allow the consumer to figure out how to get the children of each element
					getChildrenOfElement = getChildren,
					sortChildren = sortChildren })
			end
		elseif FFlagStudioFixTreeViewForSquish then
			treeNodes.Root = self.createNode(root, 0 , 0, {})
		end

		return treeNodes
	end

	-- if the tree is marked as expandAll, then show all the nodes by default
	if expandAll then
		local expandedItems = {
			[dataTreeRoot] = true,
		}
		if FFlagStudioFixTreeViewForSquish then
			self.traverseDepthFirst(dataTreeRoot, 0, {
				onNodeVisited = function(child)
					expandedItems[child] = true
				end,
				decideShouldContinue = function()
					return true
				end,
				getChildrenOfElement = getChildrenFunc,
				sortChildren = sortChildrenFunc,
			})
		else
			self.DEPRECATED_traverseDepthFirst(dataTreeRoot, 0, {
				onNodeVisited = function(child)
					expandedItems[child] = true
				end,
				decideShouldContinue = function()
					return true
				end,
				getChildrenOfElement = getChildrenFunc,
				sortChildren = sortChildrenFunc,
			})
		end
		self.state.expandedItems = expandedItems
	end

	if expandRoot then
		self.state.expandedItems = {
			[dataTreeRoot] = true,
		}
	end
end

function TreeView:render()
	return withTheme(function(theme)
		local props = self.props

		local padding = theme.treeView.scrollbar.scrollbarPadding

		local size = FFlagStudioFixTreeViewForSquish and props.Size or UDim2.new(1, -2*padding, 1, -2*padding)

		local layoutOrder = props.LayoutOrder

		local childrenPadding = not FFlagStudioFixTreeViewForSquish and UDim.new(0, theme.treeView.elementPadding) or nil

		local treeViewChildren = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = childrenPadding,
				[Roact.Ref] = self.layoutRef,
				[Roact.Change.AbsoluteContentSize] = self.resizeScrollContent,
			})
		}

		for name, node in pairs(self.getVisibleNodes()) do
			-- each of these children will be rendered by the consumer
			treeViewChildren[name] = node
		end

		return Roact.createElement("ScrollingFrame", {
			Position = UDim2.new(0, padding, 0, padding),
			Size = size,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ScrollBarThickness = theme.treeView.scrollbar.scrollbarThickness,
			ClipsDescendants = true,
			LayoutOrder = layoutOrder,

			TopImage = theme.treeView.scrollbar.topImage,
			MidImage = theme.treeView.scrollbar.midImage,
			BottomImage = theme.treeView.scrollbar.bottomImage,

			ScrollBarImageColor3 = theme.treeView.scrollbar.scrollbarImageColor,

			ElasticBehavior = Enum.ElasticBehavior.Always,
			ScrollingDirection = Enum.ScrollingDirection.XY,

			[Roact.Ref] = self.contentRef,
		}, treeViewChildren)
	end)
end

function TreeView:didUpdate()
	self.onTreeUpdated()
end

function TreeView:didMount()
	if not FFlagStudioFixTreeViewForSquish then
		local resizeSignal = self.layoutRef.current:GetPropertyChangedSignal("AbsoluteContentSize")
		self.scrollbarResizeSignalToken = resizeSignal:Connect(self.resizeScrollContent)
	end

	self.onTreeUpdated()
end

function TreeView:didUnmount()
	self.previousNodesArray = nil
	self.nodesArray = nil
	if self.scrollbarResizeSignalToken then
		self.scrollbarResizeSignalToken:Disconnect()
		self.scrollbarResizeSignalToken = nil
	end
end

return TreeView
