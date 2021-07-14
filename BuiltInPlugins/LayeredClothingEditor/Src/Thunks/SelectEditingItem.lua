-- Select item in workspace, and focus on it
local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetPreviewAssetsSelected = require(Plugin.Src.Actions.SetPreviewAssetsSelected)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)
local Constants = require(Plugin.Src.Util.Constants)
local getActivePreviewTabs = require(Plugin.Src.Util.getActivePreviewTabs)
local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)
local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)
local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)
local GetRbfPoints = require(Plugin.Src.Thunks.GetRbfPoints)
local MakeLattices = require(Plugin.Src.Thunks.MakeLattices)
local SelectPreviewTab = require(Plugin.Src.Actions.SelectPreviewTab)
local SetCagesTransparency = require(Plugin.Src.Actions.SetCagesTransparency)
local ChangeTool = require(Plugin.Src.Thunks.ChangeTool)

local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)

-- select default cage when editing item changed
local function selectCage(store, item)
	if ItemCharacteristics.isItemEmpty(item) or not ItemCharacteristics.hasAnyCage(item) then
		if ItemCharacteristics.isClothes(item) then
			store:dispatch(SetEditingCage(Constants.EDIT_MODE.Mesh))
		else
			store:dispatch(SetEditingCage(Cryo.None))
		end
		return
	end

	local defaultCageSelect =  Enum.CageType.Outer
	if not ItemCharacteristics.hasOuterCage(item) and ItemCharacteristics.hasInnerCage(item) then
		defaultCageSelect = Enum.CageType.Inner
	end
	store:dispatch(SetEditingCage(defaultCageSelect))
end

local function getPreviewPanelTab(tabs)
	local previewTab = nil
	local lowestLayoutOrder = nil
	for tabKey, tabInfo in pairs(tabs) do
		if previewTab == nil or tabInfo.LayoutOrder < lowestLayoutOrder then
			previewTab = tabKey
			lowestLayoutOrder = tabInfo.LayoutOrder
		end
	end
	if not previewTab then
		return PreviewConstants.TABS_KEYS.None
	end
	return previewTab
end

local function getPreviewTab(newEditingItem, storeState)
	local currentlySelectedTab = storeState.previewStatus.selectedTab

	local activeTabsForNewEditingItem = getActivePreviewTabs(newEditingItem)
	if not PreviewConstantsInterface.IsValidTabKey(currentlySelectedTab) then
		return getPreviewPanelTab(activeTabsForNewEditingItem)
	end

	local isTabStillAvailable =
		Cryo.List.find(Cryo.Dictionary.keys(activeTabsForNewEditingItem), currentlySelectedTab) ~= nil
	if isTabStillAvailable then
		return currentlySelectedTab
	end
	return getPreviewPanelTab(activeTabsForNewEditingItem)
end

return function(item)
	return function(store)
		local state = store:getState()

		store:dispatch(ChangeTool(Constants.TOOL_MODE.None))
		store:dispatch(SelectPreviewTab(getPreviewTab(item, state)))
		store:dispatch(SetPreviewAssetsSelected({}))
		selectCage(store, item)

		local cagesTransparency = {
			[Enum.CageType.Inner] = Constants.DEFAULT_CAGE_TRANSPARENCY,
			[Enum.CageType.Outer] = Constants.DEFAULT_CAGE_TRANSPARENCY
		}

		store:dispatch(SetCagesTransparency(cagesTransparency))
		store:dispatch(GetRbfPoints(item))
		store:dispatch(MakeLattices())

		store:dispatch(SetPast({}))
		store:dispatch(SetFuture({}))
	end
end