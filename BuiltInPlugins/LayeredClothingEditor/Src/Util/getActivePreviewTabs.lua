-- returns the active preview tabs for the editing item

local Plugin = script.Parent.Parent.Parent

local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local function getActivePreviewTabs(editingItem)
	if ItemCharacteristics.isAvatar(editingItem) then
		return PreviewConstantsInterface.getTabsForAvatarEditing()
	end
	if ItemCharacteristics.isClothes(editingItem) then
		return PreviewConstantsInterface.getTabsForClothesEditing()
	end
	return {}
end

return getActivePreviewTabs