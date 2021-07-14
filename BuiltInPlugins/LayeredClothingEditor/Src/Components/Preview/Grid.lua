--[[
	Shows the Preview Panel grid

	Required Props:
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		table API: Roblox API from Devframework for calling end points
		table PrebuiltAssetsInfo: from the rodux state, info about each prebuilt asset (name/description etc)
		callback GetPrebuiltAssetsInfo: function provided via dispatch to get name/description etc info for prebuilt assets
		callback FinishSelectingFromExplorer: function to call when we have finished adding an item as a new tile
		callback UpdatePreviewAssetsSelected: function provided via dispatch to add/remove an asset from the selected assets
		string SelectedTab: the preview tab selection (this is an entry from PreviewConstants.TABS_KEYS)
		table SelectedAssets: which assets are selected in the grid, which is provided via mapStateToProps.
		callback StartSelectingFromExplorer: function to start selecting from explorer, which mapDispatchToProps provides
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.
		string SelectorMode: enum to decide which selector should be on, which is provided via mapStateToProps
		table UserAddedAssets: the table of assets added by the user
		callback UpdateUserAddedAssets: function called when user added assets are changed

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number layoutOrder: render order of component in layout
		number zIndex: the z sorting order of the component
		Instance EditingItem: layered clothes item that is editing now, which is provided via mapStateToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UI = Framework.UI
local ScrollingFrame = UI.ScrollingFrame
local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local Typecheck = Util.Typecheck

local UpdatePreviewAssetsSelected = require(Plugin.Src.Thunks.UpdatePreviewAssetsSelected)
local GetPrebuiltAssetsInfo = require(Plugin.Src.Thunks.GetPrebuiltAssetsInfo)
local StartSelectingFromExplorer = require(Plugin.Src.Thunks.StartSelectingFromExplorer)
local FinishSelectingFromExplorer = require(Plugin.Src.Thunks.FinishSelectingFromExplorer)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Constants = require(Plugin.Src.Util.Constants)
local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)
local ShowDialog = require(Plugin.Src.Util.ShowDialog)

local Tile = require(Plugin.Src.Components.Preview.Tile)
local InstanceSelector = require(Plugin.Src.Components.InstanceSelector)
local ConfirmCancelDialog = require(Plugin.Src.Components.ConfirmCancelDialog)

local Grid = Roact.PureComponent:extend("Grid")
Typecheck.wrap(Grid, script)

local function isAssetSelectedForPreviewing(self, uniqueId)
	local props = self.props
	local selectedAssets = props.SelectedAssets
	local selectedTab = props.SelectedTab

	local selectedAssetsforTab = selectedAssets[selectedTab] or {}
	return selectedAssetsforTab[uniqueId] and true or false
end

local function createEquipTile(self, layoutOrder, zIndex, image, imageSize, uniqueId, name)
	local isCurrentlySelected = isAssetSelectedForPreviewing(self, uniqueId)
	return Roact.createElement(Tile, {
		OnClick = function()
			self.props.UpdatePreviewAssetsSelected(uniqueId, not isCurrentlySelected)
		end,
		Text = name,
		ZIndex = zIndex + 1,
		IsOn = isCurrentlySelected,
		LayoutOrder = layoutOrder,
		Image = image,
		ImageSize = imageSize,
	})
end

local function createSelectFromExplorerTile(self, layoutOrder, zIndex, panelBlockerLocalizationKey)
	local props = self.props
	local localization = props.Localization
	local theme = props.Stylizer

	return Roact.createElement(Tile, {
		OnClick = function()
			local localizedText = localization:getText(Constants.LOCALIZATION_KEYS.Preview, panelBlockerLocalizationKey)
			props.StartSelectingFromExplorer(Constants.SELECTOR_MODE.Preview, localizedText)
		end,
		Text = localization:getText(Constants.LOCALIZATION_KEYS.Preview, "AddNew"),
		ZIndex = zIndex + 1,
		IsOn = false,
		Image = theme.AddNewImage,
		ImageSize = theme.SmallImageSize,
		LayoutOrder = layoutOrder,
	})
end

function Grid:init()
	self.gridRef = Roact.createRef()

	self.isSelectedInstanceValid = function(item)
		local props = self.props

		local selectedTab = props.SelectedTab
		local editingItem = props.EditingItemContext:getItem()

		local tabInfo = PreviewConstantsInterface.getTabInfo(selectedTab)
		if not tabInfo.IsSelectedInstanceValid(item) then
			return false
		end

		local isPreviewModel = item:FindFirstAncestor("LayeredClothingEditorPreview") ~= nil
		local isEditingItem = item == editingItem
		local isMannequin = item == editingItem.Parent

		return not (isPreviewModel or isEditingItem or isMannequin)
	end

	self.onInstanceSelectorValidSelection = function(instance)
		local props = self.props

		ShowDialog(props.Plugin, props.Localization, ConfirmCancelDialog,{
			Text = self.props.Localization:getText(Constants.LOCALIZATION_KEYS.Preview, "ConfirmAddTile", {
				itemName = instance.Name,
			}),
			OnConfirm = function()
				local props = self.props
				local selectedTab = props.SelectedTab

				self.props.FinishSelectingFromExplorer(instance)
				props.UpdateUserAddedAssets(selectedTab, instance:Clone())
			end,
		})
	end
end

local function getUserAddedAssets(self, selectedTab)
	local props = self.props
	local userAddedAssets = props.UserAddedAssets

	return userAddedAssets and userAddedAssets[selectedTab] or {}
end

function Grid:render()
	local props = self.props
	local size = props.size
	local layoutOrder = props.layoutOrder or 1
	local zIndex = props.zIndex or 1
	local theme = props.Stylizer
	local selectedTab = props.SelectedTab
	local prebuiltAssetsInfo = props.PrebuiltAssetsInfo
	local localization = props.Localization
	local selectorMode = props.SelectorMode

	local children = {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellPadding = UDim2.new(0, 0, 0, 0),
			CellSize = theme.TileSize,
			FillDirectionMaxCells = 3,

			[Roact.Change.AbsoluteContentSize] = function(rbx)
				if not self.gridRef.current then
					return
				end
				self.gridRef.current.ScrollingFrame.Contents.Scroller.CanvasSize =
					UDim2.new(0, rbx.AbsoluteContentSize.X, 0, rbx.AbsoluteContentSize.Y)
			end,
		}),
	}

	local tabInfo = PreviewConstantsInterface.getTabInfo(selectedTab)
	if tabInfo then
		local orderIterator = LayoutOrderIterator.new()
		if tabInfo.CanAddNew then
			children["AddNewTile"] =
				createSelectFromExplorerTile(self, orderIterator:getNextOrder(), zIndex, tabInfo.PanelBlockerLocalizationKey)
		end

		-- add tiles for assets selected from explorer
		local userAddedAssetsForTab = getUserAddedAssets(self, selectedTab)
		for _, asset in ipairs(userAddedAssetsForTab) do
			local tileLayoutOrder = orderIterator:getNextOrder()
			local image = theme.DefaultTileImages[selectedTab]
			local name = asset.instance.Name
			children[tileLayoutOrder] =
				createEquipTile(self, tileLayoutOrder, zIndex, image, theme.SmallImageSize, asset.uniqueId, name)
		end

		-- add prebuilt asset tiles
		if tabInfo.AssetIds then
			for _, assetId in ipairs(tabInfo.AssetIds) do
				local infoForAsset = prebuiltAssetsInfo[assetId] -- will only be available on production
				if infoForAsset then
					local tileLayoutOrder = orderIterator:getNextOrder()
					local image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=150&h=150"
					local name = infoForAsset.name or localization:getText(Constants.LOCALIZATION_KEYS.Preview, "Asset")
					children[tileLayoutOrder] =
						createEquipTile(self, tileLayoutOrder, zIndex, image, nil, assetId, name)
				end
			end
		end
	end

	local isSelectorActive = selectorMode == Constants.SELECTOR_MODE.Preview
	assert((not isSelectorActive) or tabInfo, "tabInfo must be available if isSelectorActive is true")
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = size,
		LayoutOrder = layoutOrder,

		[Roact.Ref] = self.gridRef,
	}, {
		ScrollingFrame = Roact.createElement(ScrollingFrame, {
			Style = {
				BackgroundColor3 = theme.BackgroundColor,
				BorderSizePixel = 0,
				ZIndex = zIndex,
				ScrollBarThickness = theme.ScrollbarSize,
			},

			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 1, 0),
			AutoSizeCanvas = false,
		}, children),
		InstanceSelector = isSelectorActive and Roact.createElement(InstanceSelector,
		{
			IsSelectedInstanceValid = self.isSelectedInstanceValid,
			OnValidSelection = self.onInstanceSelectorValidSelection,
			InvalidSelectionWarningText =
				localization:getText(Constants.LOCALIZATION_KEYS.Preview, tabInfo.InvalidAddLocalizationKey),
		}),
	})
end

function Grid:didMount()
	local props = self.props
	local API = props.API

	local arrayOfAssetIds = PreviewConstantsInterface.getAllAssetIds()
	self.props.GetPrebuiltAssetsInfo(API, arrayOfAssetIds)
end

ContextServices.mapToProps(Grid,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	API = ContextServices.API,
	Plugin = ContextServices.Plugin,
	EditingItemContext = EditingItemContext,
})

local function mapStateToProps(state, props)
	local previewAssets = state.previewAssets
	local previewStatus = state.previewStatus
	local selectItem = state.selectItem

	return {
		PrebuiltAssetsInfo = previewAssets.prebuiltAssetsInfo,
		SelectedTab = previewStatus.selectedTab,
		SelectedAssets = previewStatus.selectedAssets,
		SelectorMode = selectItem.selectorMode,
		EditingItem = selectItem.editingItem,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		StartSelectingFromExplorer = function(mode, message)
			dispatch(StartSelectingFromExplorer(mode, message))
		end,
		GetPrebuiltAssetsInfo = function(robloxApi, arrayOfAssetIds)
			dispatch(GetPrebuiltAssetsInfo(robloxApi, arrayOfAssetIds))
		end,
		UpdatePreviewAssetsSelected = function(id, addAsset)
			dispatch(UpdatePreviewAssetsSelected(id, addAsset))
		end,
		FinishSelectingFromExplorer = function(item)
			dispatch(FinishSelectingFromExplorer())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Grid)