return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ModelPreview = require(Library.Components.Preview.ModelPreview)

	local function createTestAsset(container, name)
		local testModel = Instance.new("Model")

		local element = Roact.createElement(MockWrapper, {}, {
			ModelPreview = Roact.createElement(ModelPreview, {
				TargetModel = testModel,

				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end