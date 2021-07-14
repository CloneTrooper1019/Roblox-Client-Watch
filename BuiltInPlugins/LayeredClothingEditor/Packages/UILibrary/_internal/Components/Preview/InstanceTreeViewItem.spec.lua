return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local TreeViewItem = require(Library.Components.Preview.InstanceTreeViewItem)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			TreeViewItem = Roact.createElement(TreeViewItem, {
				element = Instance.new("Part"),
				indent = 0,
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local element = Roact.createElement(MockWrapper, {}, {
			TreeViewItem = Roact.createElement(TreeViewItem, {
				element = Instance.new("Part"),
				indent = 0,
				canExpand = true,
			}),
		})
		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "TreeViewItem")

		local treeViewItem = container.TreeViewItem
		expect(treeViewItem).to.be.ok()
		expect(treeViewItem.Padding).to.be.ok()
		expect(treeViewItem.Layout).to.be.ok()
		expect(treeViewItem.Expand).to.be.ok()
		expect(treeViewItem.Expand.ExpandIcon).to.be.ok()
		expect(treeViewItem.Icon).to.be.ok()
		expect(treeViewItem.Name).to.be.ok()
		expect(treeViewItem.HoverFolder).to.be.ok()
		expect(treeViewItem.HoverFolder.Hover).to.be.ok()

		Roact.unmount(instance)
	end)
end
