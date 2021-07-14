return function()
	local AssetType = require(script.Parent.AssetType)

	describe("isPreviewAvailable()", function()
		it("should make sure the assetPreviewType is nil.", function()
			expect(function()
				AssetType:isPreviewAvailable(nil)
			end).to.throw()
		end)

		it("should show preview for sound.", function()
			local typeId = Enum.AssetType.Audio.Value
			local result = AssetType:isPreviewAvailable(typeId)
			expect(result).to.equal(true)
		end)

		it("should not show preview for LeftArm.", function()
			local typeId = Enum.AssetType.LeftArm.Value
			local result = AssetType:isPreviewAvailable(typeId)
			expect(result).to.equal(false)
		end)
	end)

end
