return function()
	local AssetRenderUtil = require(script.Parent.AssetRenderUtil)

	describe("getRenderType", function()
		it("returns nil for non-instance", function()
			expect(AssetRenderUtil:getRenderType({})).to.equal(nil)
		end)

		it("returns Other for unmapped type", function()
			expect(AssetRenderUtil:getRenderType(Instance.new("Animation"))).to.equal(AssetRenderUtil.AssetRenderType.Other)
		end)

		it("returns mapped type", function()
			expect(AssetRenderUtil:getRenderType(Instance.new("Model"))).to.equal(AssetRenderUtil.AssetRenderType.Model)
		end)
	end)
end