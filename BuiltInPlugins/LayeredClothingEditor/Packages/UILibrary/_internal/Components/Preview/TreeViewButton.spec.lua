return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local TreeViewButton = require(Library.Components.Preview.TreeViewButton)

	local function createTestAsset(container, name)
		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(TreeViewButton, {
				Position = UDim2.new(1, 0, 1, 0),

				ShowTreeView = false,
				OnTreeviewStatusToggle = nil,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end