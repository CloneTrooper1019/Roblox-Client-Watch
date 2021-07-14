--[[
	Add preview avatars to the scene and add preview clothes to the preview avatar or editing avatar

	Optional Props:
		table SelectedAssets: which assets are selected in the grid, which is provided via mapStateToProps.
		table UserAddedAssets: the table of assets added by the user
		table PointData: Rbf point data for the cages being edited, provided via mapStateToProps.
		table AttachmentPoint: CFrame data for item attachment, provided via mapStateToProps.
		table AccessoryTypeInfo: Info about accessory asset type and bounds, provided via mapStateToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
		table PreviewContext: A PreviewContext item, which is provided via mapToProps.

]]

local InsertService = game:GetService("InsertService")

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)
local PreviewContext = require(Plugin.Src.Context.PreviewContext)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util
local Typecheck = Util.Typecheck

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local ExplorerPreviewInstances = Roact.PureComponent:extend("ExplorerPreviewInstances")
Typecheck.wrap(ExplorerPreviewInstances, script)

function ExplorerPreviewInstances:init()
	self.folderRef = Roact.createRef()
	self.editingItemClones = {}
end

function ExplorerPreviewInstances:render()
	return Roact.createElement(Roact.Portal, {
		target = game.Workspace
	}, {
		LayeredClothingEditorPreview = Roact.createElement("Folder", {
			[Roact.Ref] = self.folderRef,
			Archivable = false,
		}),
	})
end

local function getModelFromBackend(assetId)
	local containerModel = nil
	local model = nil
	local success, err = pcall(function()
		containerModel = InsertService:LoadAsset(assetId)
		model = containerModel:GetChildren()[1]
	end)
	if success then
		model.Parent = nil
		model.Archivable = false
		containerModel:Destroy()
		return model
	else
		warn("unable to insert model because: " .. err)
	end
end

local function getModelFromUserAddedAssets(self, uniqueId, tabKey)
	local props = self.props
	local userAddedAssets = props.UserAddedAssets

	if not userAddedAssets or not userAddedAssets[tabKey] then
		return
	end

	for _, asset in ipairs(userAddedAssets[tabKey]) do
			if asset.uniqueId == uniqueId then
				local result = asset.instance:Clone()
				result.Archivable = false
				return result
			end
		end
	end

local function getModel(self, uniqueId, tabKey)
	local result = getModelFromUserAddedAssets(self, uniqueId, tabKey)
	if result then
		return result
	end
	local isInt = (type(uniqueId) == "number") and (math.floor(uniqueId) == uniqueId)
	assert(isInt, "if the uniqueId does not refer to a user added asset it must be an integer referring to an assetId")
	return isInt and getModelFromBackend(uniqueId) or nil
end

local function getSelectedUniqueIds(self, tabKey)
	local props = self.props
	local selectedAssets = props.SelectedAssets
	return selectedAssets[tabKey] or {}
end

local function removePreviewAvatars(self)
	self.props.PreviewContext:destroyAvatars()

	for _, clothes in ipairs(self.editingItemClones) do
		clothes:Destroy()
	end

	self.editingItemClones = {}
end

local function fetchPreviewAvatar(self)
	local requiredPreviewAvatarUniqueIds = getSelectedUniqueIds(self, PreviewConstants.TABS_KEYS.Avatars)
	for uniqueId in pairs(requiredPreviewAvatarUniqueIds) do
		local previewAvatar = getModel(self, uniqueId, PreviewConstants.TABS_KEYS.Avatars)
		if previewAvatar then
			ModelUtil:positionAvatar(previewAvatar, self.props.EditingItemContext:getItem())
			previewAvatar.Parent = self.folderRef.current
			previewAvatar.Name = PreviewConstants.PreviewAvatarName
			self.props.PreviewContext:addAvatar(previewAvatar)
		end
	end
end

local function removePreviewClothes(self)
	self.props.PreviewContext:destroyItems()
end

local function applyAllSelectedClothing(self, avatar)
	local requiredPreviewClothesUniqueIds = getSelectedUniqueIds(self, PreviewConstants.TABS_KEYS.Clothing)
	for uniqueId in pairs(requiredPreviewClothesUniqueIds) do
		local previewClothes = getModel(self, uniqueId, PreviewConstants.TABS_KEYS.Clothing)
		if previewClothes then
			previewClothes.Name = uniqueId
			ModelUtil:attachClothingItem(avatar, previewClothes)
			self.props.PreviewContext:addItem(previewClothes)
		end
	end
end

local function fetchPreviewClothes(self)
	local editingItem = self.props.EditingItemContext:getItem()
	if ItemCharacteristics.isAvatar(editingItem) then
		applyAllSelectedClothing(self, editingItem)
	elseif ItemCharacteristics.isClothes(editingItem) then
		for _, avatar in ipairs(self.props.PreviewContext:getAvatars()) do
			-- temporarily make editingItem archivable so that we can clone it
			editingItem.Archivable = true
			local clothingClone = editingItem:Clone()
			editingItem.Archivable = false

			clothingClone.Archivable = false
			ModelUtil:attachClothingItem(avatar, clothingClone)
			applyAllSelectedClothing(self, avatar)
			table.insert(self.editingItemClones, clothingClone)
		end
	end
end

local function updatePreviewAttachments(self)
	for _, clone in ipairs(self.editingItemClones) do
		if self.props.AccessoryTypeInfo then
			-- need to detach weld first
			local weld = clone:FindFirstChildWhichIsA("WeldConstraint")
			local part1 = weld.Part1
			weld:Destroy()
			local bodyAttachment = ModelUtil:findAvatarAttachmentByName(clone.Parent, self.props.AccessoryTypeInfo.Name)
			if not bodyAttachment then
				continue
			end
			clone.CFrame = bodyAttachment.WorldCFrame * self.props.AttachmentPoint.ItemCFrame
			ModelUtil:addAttachment(clone, clone.Parent, self.props.AccessoryTypeInfo, self.props.AttachmentPoint.AttachmentCFrane)
			-- add weld back
			ModelUtil:addWeld(nil, clone, part1, clone)
		end
	end
end

local function updatePreviewDeformations(self)
	for _, item in ipairs(self.editingItemClones) do
		ModelUtil:deformClothing(item, self.props.PointData, self.props.EditingCage)
	end
end

local function updatePreviewAssets(self, removeOldAssets, fetchNewAsets)
	coroutine.wrap(function()
		while self.isUpdateInProgress do
			wait()
		end

		self.isUpdateInProgress = true
		if removeOldAssets then
			removePreviewClothes(self)
			removePreviewAvatars(self)
		end

		if fetchNewAsets then
		fetchPreviewAvatar(self)
		fetchPreviewClothes(self)
		end

		updatePreviewDeformations(self)
		updatePreviewAttachments(self)
		self.isUpdateInProgress = false
	end)()
end

function ExplorerPreviewInstances:didMount()
	updatePreviewAssets(self, false, true)
end

function ExplorerPreviewInstances:didUpdate(prevProps)
	if prevProps.SelectedAssets[PreviewConstants.TABS_KEYS.Avatars] ~= self.props.SelectedAssets[PreviewConstants.TABS_KEYS.Avatars] or
		prevProps.SelectedAssets[PreviewConstants.TABS_KEYS.Clothing] ~= self.props.SelectedAssets[PreviewConstants.TABS_KEYS.Clothing]then
		updatePreviewAssets(self, true, true)
	else
		updatePreviewAssets(self, false, false)
	end
end

function ExplorerPreviewInstances:willUnmount()
	updatePreviewAssets(self, true, false)
end

local function mapStateToProps(state, props)
	local previewStatus = state.previewStatus
	local selectItem = state.selectItem
	local cageData = state.cageData

	return {
		AttachmentPoint = selectItem.attachmentPoint,
		AccessoryTypeInfo = selectItem.accessoryTypeInfo,
		SelectedAssets = previewStatus.selectedAssets,
		EditingCage = selectItem.editingCage,
		PointData = cageData.pointData,
	}
end

ContextServices.mapToProps(ExplorerPreviewInstances,{
	EditingItemContext = EditingItemContext,
	PreviewContext = PreviewContext,
})

return RoactRodux.connect(mapStateToProps)(ExplorerPreviewInstances)