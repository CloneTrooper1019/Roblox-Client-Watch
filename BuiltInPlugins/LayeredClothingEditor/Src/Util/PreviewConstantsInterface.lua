--[[
	Provides an interface of functions to get information from PreviewConstants.lua
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

local PreviewConstantsInterface = {}

function PreviewConstantsInterface.IsValidTabKey(tabKey)
	return tabKey ~= PreviewConstants.TABS_KEYS.None
end

function PreviewConstantsInterface.getTabInfo(tabSelect)
	return PreviewConstantsInterface.IsValidTabKey(tabSelect) and PreviewConstants.TABS_INFO[tabSelect] or nil
end

-- are the tab selections multi or singular select
function PreviewConstantsInterface.isTabMultiSelect(tabSelect)
	local tab = PreviewConstants.TABS_INFO[tabSelect]
	return tab.IsMultiSelect
end

-- returns an array of asset ids
function PreviewConstantsInterface.getAllAssetIds()
	local function getAllPrebuiltAssetIdsInternal(tbl, assetIdKeyedTable)
		assetIdKeyedTable = assetIdKeyedTable or {}
		for key, value in pairs(tbl) do
			if key == "AssetIds" then
				for _, assetId in pairs(value) do
					local unusedValue = true
					assetIdKeyedTable[assetId] = unusedValue
				end
			elseif type(value) == "table" then
				getAllPrebuiltAssetIdsInternal(value, assetIdKeyedTable)
			end
		end
		return assetIdKeyedTable
	end

	local assetIdKeyedTable = getAllPrebuiltAssetIdsInternal(PreviewConstants.TABS_INFO)
	local arrayOfAssetIds = Cryo.Dictionary.keys(assetIdKeyedTable)
	return arrayOfAssetIds
end

function PreviewConstantsInterface.getTabs()
	return PreviewConstants.TABS_INFO
end

function PreviewConstantsInterface.getTabsForAvatarEditing()
	local tabsForAvatarEditing = {}
	for tabKey,data in pairs(PreviewConstantsInterface.getTabs()) do
		if tabKey ~= PreviewConstants.TABS_KEYS.Avatars then
			tabsForAvatarEditing[tabKey] = data
		end
	end
	return tabsForAvatarEditing
end

function PreviewConstantsInterface.getTabsForClothesEditing()
	return PreviewConstantsInterface.getTabs()
end

function PreviewConstantsInterface.shouldTabShowTransparency(tabKey)
	return PreviewConstantsInterface.IsValidTabKey(tabKey) and tabKey ~= PreviewConstants.TABS_KEYS.Animations
end

function PreviewConstantsInterface.shouldTabShowPlaybackSlider(tabKey)
	return PreviewConstantsInterface.IsValidTabKey(tabKey) and tabKey == PreviewConstants.TABS_KEYS.Animations
end

return PreviewConstantsInterface