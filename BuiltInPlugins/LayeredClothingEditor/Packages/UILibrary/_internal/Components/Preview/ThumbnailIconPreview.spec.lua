return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ThumbnailIconPreview = require(Library.Components.Preview.ThumbnailIconPreview)

	local function createTestAsset(container, name)
		local targetInstance = Instance.new("Script")
		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(ThumbnailIconPreview, {
				TargetInstance = targetInstance,
				TextContent = "ThumbnailIconPreviewTest",
				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.new(0, 100, 0, 20)
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end