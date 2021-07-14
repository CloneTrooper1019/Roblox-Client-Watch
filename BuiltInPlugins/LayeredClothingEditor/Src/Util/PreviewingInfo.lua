-- Get preview item in current selected tab

local Plugin = script.Parent.Parent.Parent
local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

local PreviewingInfo = {}

function PreviewingInfo.getPreviewingAnimationId(state)
	-- todo: might change later
	-- currently get the first animation selected in animation tab
	local previewStatus = state.previewStatus
	local selectedAssets = previewStatus.selectedAssets
	if not selectedAssets or not selectedAssets[PreviewConstants.TABS_KEYS.Animations] then
		return
	end

	local animationAssetId = next(selectedAssets[PreviewConstants.TABS_KEYS.Animations])
	if animationAssetId then
		if PreviewConstants.AnimationIdToSequenceId[animationAssetId] then
			return PreviewConstants.AnimationIdToSequenceId[animationAssetId]
		else
			warn("Animation id "..tostring(animationAssetId).." does not have sequence id defined")
		end
	end
	return nil
end


return PreviewingInfo