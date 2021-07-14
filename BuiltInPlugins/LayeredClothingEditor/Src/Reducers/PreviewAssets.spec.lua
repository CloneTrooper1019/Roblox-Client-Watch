return function()
	local Plugin = script.Parent.Parent.Parent

	local SetPrebuiltAssetsInfo = require(Plugin.Src.Actions.SetPrebuiltAssetsInfo)

	local PreviewAssets = require(Plugin.Src.Reducers.PreviewAssets)

	it("should return a table", function()
		local state = PreviewAssets(nil, {})

		expect(type(state)).to.equal("table")
	end)

	describe("SetPrebuiltAssetsInfo action", function()
		it("should get copied to state correctly", function()
			local state = PreviewAssets(nil, {})

			local assetId = 12345
			local assetName = "my asset"
			local assetsInfo = {
				[assetId] = {
					name = assetName
				}
			}

			state = PreviewAssets(state, SetPrebuiltAssetsInfo(assetsInfo))

			expect(state.prebuiltAssetsInfo[assetId]).to.be.ok()
			expect(state.prebuiltAssetsInfo[assetId].name).to.equal(assetName)
		end)
	end)
end
