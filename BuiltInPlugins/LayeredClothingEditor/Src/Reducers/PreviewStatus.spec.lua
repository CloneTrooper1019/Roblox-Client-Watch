return function()
	local Plugin = script.Parent.Parent.Parent

	local SetPreviewAssetsSelected = require(Plugin.Src.Actions.SetPreviewAssetsSelected)
	local SelectPreviewTab = require(Plugin.Src.Actions.SelectPreviewTab)

	local PreviewStatus = require(Plugin.Src.Reducers.PreviewStatus)

	local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

	it("should return a table", function()
		local state = PreviewStatus(nil, {})

		expect(type(state)).to.equal("table")
	end)

	describe("SelectPreviewTab action", function()
		it("should get copied to state correctly", function()
			local state = PreviewStatus(nil, {})

			local newTab = PreviewConstants.TABS_KEYS.Animations

			state = PreviewStatus(state, SelectPreviewTab(newTab))

			expect(state.selectedTab).to.equal(newTab)
		end)
	end)

	describe("SetPreviewAssetsSelected action", function()
		it("should get copied to state correctly", function()
			local state = PreviewStatus(nil, {})

			local assetId = 12345
			local assetsSelected = {
				[PreviewConstants.TABS_KEYS.Avatars] = {
					[assetId] = true
				}
			}

			state = PreviewStatus(state, SetPreviewAssetsSelected(assetsSelected))

			expect(state.selectedAssets[PreviewConstants.TABS_KEYS.Avatars]).to.be.ok()

			local assetTable = state.selectedAssets[PreviewConstants.TABS_KEYS.Avatars]
			expect(assetTable[assetId]).to.equal(true)
		end)
	end)
end
