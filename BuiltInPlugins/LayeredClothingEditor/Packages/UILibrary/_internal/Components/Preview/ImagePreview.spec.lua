return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ImagePreview = require(Library.Components.Preview.ImagePreview)

	local function createTestAsset(container, name)
		local image = "rbxasset://textures/AnimationEditor/animation_editor_blue.png"
		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(ImagePreview, {
				ImageContent = image,
				TextContent = "ImagePreviewTest",
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