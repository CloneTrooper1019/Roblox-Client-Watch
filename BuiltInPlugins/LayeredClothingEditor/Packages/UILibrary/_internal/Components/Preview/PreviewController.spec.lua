return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local PreviewController = require(Library.Components.Preview.PreviewController)

	local AssetType = require(Library.Utils.AssetType)

	-- PineTree
	-- rbxassetid://183435411
	local function createTestAsset(container, name)
		local assetId = 183435411
		local previewModel = Instance.new("Model")

		local element = Roact.createElement(MockWrapper, {}, {
			PreviewController = Roact.createElement(PreviewController, {
				width = 40,

				currentPreview = previewModel,
				previewModel = previewModel,
				assetPreviewType = AssetType.TYPES.ModelType,
				assetId = assetId,
				putTreeviewOnBottom = true,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end