--[[
	Workspace instance of the item being edited. If it's a clothing item/accessory, the item will be
	automatically attached to a default mannequin.

	Optional Props:
		table AccessoryTypeInfo: Accessory type name, attachment point, and bounds
		enum EditingCage: Cage type identifier, Inner/Outer, provided via mapStateToProps
		table PointData: vertex data of item being edited, provided via mapStateToProps
		callback SelectEditingItem: update store values when editing item is selected, provided via mapDispatchToProps
]]

local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local SelectEditingItem = require(Plugin.Src.Thunks.SelectEditingItem)
local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Constants = require(Plugin.Src.Util.Constants)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util
local Typecheck = Util.Typecheck

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local SelectedEditingItem = Roact.PureComponent:extend("SelectedEditingItem")
Typecheck.wrap(SelectedEditingItem, script)

local function terminateConnections(self)
	if self.DescendantAddedHandle then
		self.DescendantAddedHandle:Disconnect()
		self.DescendantAddedHandle = nil
	end

	if self.DescendantRemovedHandle then
		self.DescendantRemovedHandle:Disconnect()
		self.DescendantRemovedHandle = nil
	end

	if self.AncestryChangedHandle then
		self.AncestryChangedHandle:Disconnect()
		self.AncestryChangedHandle = nil
	end
end

local function destroyEditingItem(self)
	self.props.EditingItemContext:setEditingItem(nil)

	terminateConnections(self)

	if self.mannequin then
		self.mannequin:Destroy()
		self.mannequin = nil
	end

	if self.editingItem then
		self.editingItem:Destroy()
		self.editingItem = nil
	end
end

local function setupConnections(self, target)
	self.DescendantAddedHandle = target.DescendantAdded:Connect(self.onEditingItemExternalChange)
	self.DescendantRemovedHandle = target.DescendantRemoving:Connect(self.onEditingItemExternalChange)
	self.AncestryChangedHandle = target.AncestryChanged:Connect(self.onEditingItemExternalChange)
end

local function setupEditingItem(self, regenerated)
	self.sourceItem = self.props.EditingItemContext:getSourceItem()
	if not self.sourceItem then
		return
	end
	self.editingItem = self.sourceItem:Clone()
	self.editingItem.Archivable = false
	self.editingItem.Name = HttpService:GenerateGUID()
	self.props.EditingItemContext:setEditingItem(self.editingItem)

	terminateConnections(self)
	if ItemCharacteristics.isClothes(self.editingItem) then
		self.mannequin = InsertService:LoadLocalAsset("rbxasset://models/LayeredClothingEditor/mannequin.rbxm")
		self.mannequin.Parent = game.Workspace

		if self.props.AccessoryTypeInfo then
			ModelUtil:addAttachment(self.editingItem, self.mannequin, self.props.AccessoryTypeInfo)
		end

		ModelUtil:positionAvatar(self.mannequin, self.editingItem, not regenerated)
		ModelUtil:attachClothingItem(self.mannequin, self.editingItem)
		setupConnections(self, self.mannequin)
	else
		self.editingItem.Parent = game.Workspace
		ModelUtil:positionAvatar(self.editingItem, self.sourceItem, not regenerated)
		setupConnections(self, self.editingItem)
	end

	if not regenerated then
		self.props.SelectEditingItem(self.editingItem)
		spawn(function()
			ModelUtil:focusCameraOnItem(self.editingItem)
		end)
	end
end

function SelectedEditingItem:init()
	self.mannequin = nil
	self.editingItem = nil

	self.onEditingItemExternalChange = function()
		destroyEditingItem(self)
		setupEditingItem(self, true)
	end

	self.onSourceItemChanged = function(sourceItem)
		destroyEditingItem(self)
		setupEditingItem(self, self.sourceItem == sourceItem)
	end
end

-- We are not rendering the mannequin/editing item directly through Roact since we wonly want
-- it to be tied to mounting/unmounting of the component. Render will be responsible for re-triggering
-- deformation updates when pointData prop changes.
function SelectedEditingItem:render()
	local props = self.props

	local pointData = props.PointData
	local editingCage = props.EditingCage

	if not self.editingItem or not ItemCharacteristics.hasAnyCage(self.editingItem) or not next(pointData) then
		return nil
	end

	if editingCage == Constants.EDIT_MODE.Mesh then
		return nil
	end

	if ItemCharacteristics.isClothes(self.editingItem) then
		ModelUtil:deformClothing(self.editingItem, pointData, editingCage)
	else
		ModelUtil:updateWraps(pointData, editingCage)
	end
end

function SelectedEditingItem:didMount()
	local props = self.props
	self.SourceItemChangedHandle = props.EditingItemContext:getSourceItemChangedSignal():Connect(self.onSourceItemChanged)
end

function SelectedEditingItem:didUpdate(prevProps)
	if prevProps.AccessoryTypeInfo ~= self.props.AccessoryTypeInfo then
		destroyEditingItem(self)
		setupEditingItem(self, true)
	end
end

function SelectedEditingItem:willUnmount()
	destroyEditingItem(self)

	if self.SourceItemChangedHandle then
		self.SourceItemChangedHandle:Disconnect()
		self.SourceItemChangedHandle = nil
	end

	self.sourceItem = nil
end

local function mapStateToProps(state, props)
	local selectItem = state.selectItem
	local cageData = state.cageData

	return {
		AccessoryTypeInfo = selectItem.accessoryTypeInfo,
		EditingCage = selectItem.editingCage,
		PointData = cageData.pointData,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SelectEditingItem = function(item)
			dispatch(SelectEditingItem(item))
		end,
	}
end

ContextServices.mapToProps(SelectedEditingItem,{
	EditingItemContext = EditingItemContext,
})

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(SelectedEditingItem)