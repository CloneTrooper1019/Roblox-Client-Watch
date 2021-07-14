--[[
	set which preview assets are currently selected

	Params:
		number assetId: the key of the preview tab to select
		boolean isAddingAsset: true means we're adding this asset, false means we're removing
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetPreviewAssetsSelected = require(Plugin.Src.Actions.SetPreviewAssetsSelected)

local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)

local function getUpdatedSelectedAssetsForTab(id, isAddingAsset, isMultiSelect, selectedAssetsForTab)
	if isMultiSelect then
		return Cryo.Dictionary.join(selectedAssetsForTab or {}, {
			[id] = isAddingAsset and true or Cryo.None
		})
	end

	if isAddingAsset then
		return {[id] = true}
	end
	return selectedAssetsForTab and Cryo.Dictionary.join(selectedAssetsForTab, {
		[id] = Cryo.None
	}) or nil
end

return function(id, isAddingAsset)
	return function(store)
		local state = store:getState()
		local selectedTab = state.previewStatus.selectedTab

		local newSelectedAssets = Cryo.Dictionary.join(state.previewStatus.selectedAssets, {})
		local isTabMultiSelect = PreviewConstantsInterface.isTabMultiSelect(selectedTab)
		newSelectedAssets[selectedTab] =
			getUpdatedSelectedAssetsForTab(id, isAddingAsset, isTabMultiSelect, newSelectedAssets[selectedTab])

		store:dispatch(SetPreviewAssetsSelected(newSelectedAssets))
	end
end