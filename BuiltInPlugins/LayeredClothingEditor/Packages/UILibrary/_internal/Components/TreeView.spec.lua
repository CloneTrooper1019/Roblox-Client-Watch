local TreeView = require(script.Parent.TreeView)

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local MockWrapper = require(Library.MockWrapper)

local FFlagStudioFixTreeViewForSquish = settings():GetFFlag("StudioFixTreeViewForSquish")

local function mockDataNode(value, parent)
	local Node = {
		Value = value,
		Children = {},
	}

	if parent then
		table.insert(parent.Children, Node)
	end

	return Node
end

local function mockDataTree()
	local root = mockDataNode("Players")
	local node1 = mockDataNode("John Doe", root)
	local node2 = mockDataNode("Jane Doe", root)
	local node3 = mockDataNode("Builderman", root)
	mockDataNode("Sword", node1)
	mockDataNode("Shield", node1)
	mockDataNode("Gun", node2)
	mockDataNode("Hammer", node3)

	return root
end

local function mockGetChildren(node)
	return node.Children
end

local function mockRenderElement(props)
	return Roact.createElement("Frame",{})
end

local function mockSortChildren(nodeA, nodeB)
	return nodeA.Value > nodeB.Value
end

return function()
	describe("TreeView", function()
		it("should create and destroy without errors", function()
			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = mockRenderElement,

					-- optional props
					sortChildren = mockSortChildren,
				}),
			})
			local container = Instance.new("Frame")
			local instance = Roact.mount(element, container)
			Roact.unmount(instance)
		end)

		it("should error when it is missing important props", function()
			expect(function()
				local element = Roact.createElement(MockWrapper, {}, {
					TreeView = Roact.createElement(TreeView, {
						dataTree = mockDataTree(),
						getChildren = mockGetChildren,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end).to.throw()

			expect(function()
				local element = Roact.createElement(MockWrapper, {}, {
					TreeView = Roact.createElement(TreeView, {
						dataTree = mockDataTree,
						renderElement = mockRenderElement,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end).to.throw()

			expect(function()
				local element = Roact.createElement(MockWrapper, {}, {
					TreeView = Roact.createElement(TreeView, {
						getChildren = mockGetChildren,
						renderElement = mockRenderElement,
					}),
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end).to.throw()
		end)

		it("should render correctly", function()
			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = mockRenderElement,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			local treeView = container:FindFirstChildOfClass("ScrollingFrame")
			expect(treeView).to.be.ok()
			expect(treeView.Root).to.be.ok()
			expect(treeView.Layout).to.be.ok()

			Roact.unmount(instance)
		end)

		it("should render the children when you expand the node", function()
			local nodesRenderedCount = 0
			local expandChildFunc
			local function renderElement(props)
				-- if rendering the root node, grab the callback to expand it
				if props.element.Value == "Players" then
					expandChildFunc = props.toggleExpanded
				end

				nodesRenderedCount = nodesRenderedCount + 1

				-- create an element
				return Roact.createElement("TextLabel", {
					Text = props.element.Value
				}, props.children)
			end

			local count = 0
			local function dfCount(root)
				local children = root:GetChildren()
				count = count + 1

				if #children == 0 then
					return
				end

				for _, child in ipairs(children) do
					dfCount(child)
				end
			end

			-- render the tree
			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = renderElement,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)
			local treeView = container:FindFirstChildOfClass("ScrollingFrame")

			-- Remove with FFlagStudioFixTreeViewForSquish
			local renderedChildren
			renderedChildren = treeView:GetChildren()

			if FFlagStudioFixTreeViewForSquish then
				dfCount(treeView)
				expect(count).to.equal(nodesRenderedCount + 2)-- should equal number of nodes + 1 UIListLayout + 1 for RoactTree
			else
				expect(#renderedChildren).to.equal(nodesRenderedCount + 1)-- should equal number of nodes + 1 UIListLayout
			end
			expect(nodesRenderedCount).to.equal(1)

			-- expand the root node, it should re-render the root node and its three children
			nodesRenderedCount = 0
			expandChildFunc()

			-- it should have rendered the children
			treeView = container:FindFirstChildOfClass("ScrollingFrame")
			renderedChildren = treeView:GetChildren()
			if FFlagStudioFixTreeViewForSquish then
				count = 0
				dfCount(treeView)
				expect(count).to.equal(nodesRenderedCount + 2)-- should equal number of nodes + 1 UIListLayout + 1 for RoactTree
			else
				expect(#renderedChildren).to.equal(nodesRenderedCount + 1)-- should equal number of nodes + 1 UIListLayout
			end

			local foundChildNodes = 0
			local foundRoot = false
			local foundChild1 = false
			local foundChild2 = false
			local foundChild3 = false
			if FFlagStudioFixTreeViewForSquish then
				local function dfs(node)
					local children = node:GetChildren()

					if node:IsA("TextLabel") then
						foundChildNodes = foundChildNodes + 1
						if node.Text == "Players" then
							foundRoot = true
						elseif node.Text == "John Doe" then
							foundChild1 = true
						elseif node.Text == "Jane Doe" then
							foundChild2 = true
						elseif node.Text == "Builderman" then
							foundChild3 = true
						end
					end

					if #children == 0 then
						return
					end

					for _, child in ipairs(children) do
						dfs(child)
					end
				end

				dfs(treeView)
			else
				for _, childNode in ipairs(renderedChildren) do
					if childNode:IsA("TextLabel") then
						foundChildNodes = foundChildNodes + 1
						if childNode.Text == "Players" then
							foundRoot = true
						elseif childNode.Text == "John Doe" then
							foundChild1 = true
						elseif childNode.Text == "Jane Doe" then
							foundChild2 = true
						elseif childNode.Text == "Builderman" then
							foundChild3 = true
						end
					end
				end
			end
			expect(foundChildNodes).to.equal(nodesRenderedCount)
			expect(foundRoot).to.equal(true)
			expect(foundChild1).to.equal(true)
			expect(foundChild2).to.equal(true)
			expect(foundChild3).to.equal(true)

			-- clean up
			Roact.unmount(instance)
		end)

		it("should allow you to select one or multiple elements in the tree", function()
			local isRootSelected = false
			local selectNodeFunc

			local function renderElement(props)
				isRootSelected = props.isSelected
				selectNodeFunc = props.toggleSelected

				return Roact.createElement("Frame")
			end

			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = renderElement,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			-- select the root node
			expect(isRootSelected).to.equal(false)
			selectNodeFunc()
			expect(isRootSelected).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should render all of the children immediately if expandAll is set", function()
			local nodeCount = 0
			local renderElement = function(props)
				nodeCount = nodeCount + 1
				return Roact.createElement("Frame", {}, props.children)
			end

			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = renderElement,
					expandAll = true,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			local treeView = container:FindFirstChildOfClass("ScrollingFrame")
			local treeViewChildren = treeView:GetChildren()

			local count = 0
			local function dfCount(root)
				local children = root:GetChildren()
				count = count + 1

				if #children == 0 then
					return
				end

				for _, child in ipairs(children) do
					dfCount(child)
				end
			end

			-- mockDataTree has 8 nodes
			expect(nodeCount).to.equal(8)
			if FFlagStudioFixTreeViewForSquish then
				dfCount(treeView)
				expect(count).to.equal(nodeCount + 2)
			else
				-- there should be 8 nodes + 1 UIListLayout
				expect(#treeViewChildren).to.equal(nodeCount + 1)
			end

			Roact.unmount(instance)
		end)

		itSKIP("should fire update callback", function()
			local nodeCount = 0
			local renderElement = function(props)
				nodeCount = nodeCount + 1
				return Roact.createElement("Frame", {})
			end

			local numInvoked = 0
			local treeList = nil
			local element = Roact.createElement(MockWrapper, {}, {
				TreeView = Roact.createElement(TreeView, {
					dataTree = mockDataTree(),
					getChildren = mockGetChildren,
					renderElement = renderElement,
					expandAll = true,
					onTreeUpdated = function(tree)
						treeList = tree
						numInvoked = numInvoked + 1
					end,
				}),
			})
			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			expect(treeList).to.be.ok()
			expect(#treeList).to.equal(nodeCount)
			expect(numInvoked).to.equal(1)

			Roact.unmount(instance)
		end)
	end)
end
