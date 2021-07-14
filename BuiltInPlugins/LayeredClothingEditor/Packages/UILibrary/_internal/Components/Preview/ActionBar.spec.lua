return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ActionBar = require(Library.Components.Preview.ActionBar)

	local function createTestAsset(container, name)
		local element = Roact.createElement(MockWrapper, {}, {
				Roact.createElement(ActionBar, {
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					AnchorPoint = Vector2.new(0, 1),
					Text = "foo",
				})
			})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end