--[[
	Screen for selecting AssetType and initial attachment point of the accesory. This screen gets
	skipped if the editing item is an Avatar.

	Required Props:
		callback GoToNext: request to go to next screen in flow.
		callback GoToPrevious: request to go to previous screen in flow.
		callback SetAccessoryTypeInfo: action to set table info for accessory type, provided via mapDispatchToProps
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
		table Localization: A Localization ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Pane = Framework.UI.Pane

local SetAccessoryTypeInfo = require(Plugin.Src.Actions.SetAccessoryTypeInfo)

local LCERadioButtonList = require(Plugin.Src.Components.LCERadioButtonList)
local FlowScreenLayout = require(Plugin.Src.Components.Screens.FlowScreenLayout)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Constants = require(Plugin.Src.Util.Constants)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local Util = Framework.Util
local Typecheck = Util.Typecheck
local LayoutOrderIterator = Util.LayoutOrderIterator

local AssetTypeScreen = Roact.PureComponent:extend("AssetTypeScreen")

Typecheck.wrap(AssetTypeScreen, script)

local function makeButtonList(localization, keys)
	local buttons = {}
	for key in pairs(keys) do
		table.insert(buttons, {
			Key = key,
			Text = localization:getText("AssetType", key),
			Disabled = false,
		})
	end
	return buttons
end

local function hasMultipleAttachments(assetTypeInfo)
	local att = assetTypeInfo.Attachments
	local count = 0
	for _ in pairs(att) do
		count = count + 1
		if count > 1 then
			return true
		end
	end
	return false
end

function AssetTypeScreen:init()
	self.state = {
		multiAttachmentAsset = nil,
	}

	self.multiAttachmentAsset = nil

	self.onNext = function()
		if self.multiAttachmentAsset then
			self:setState({
				multiAttachmentAsset = Cryo.Dictionary.join(self.multiAttachmentAsset),
			})
		else
			self.props.GoToNext()
		end
	end

	self.onBack = function()
		if self.multiAttachmentAsset then
			self:setState({
				multiAttachmentAsset = Roact.None,
			})
		else
			self.props.GoToPrevious()
		end
	end

	self.onClickAttachment = function(attachment)
		local editingItem = self.props.EditingItemContext:getItem()
		if not editingItem then
			return
		end
		self.multiAttachmentAsset = nil
		self.props.SetAccessoryTypeInfo(Cryo.Dictionary.join(attachment))
	end

	self.onClickAttachmentSubList = function(key, assetTypeInfo)
		if assetTypeInfo and key and assetTypeInfo.Attachments[key] then
			self.onClickAttachment(assetTypeInfo.Attachments[key])
		end
	end

	self.onClickAssetType = function(key, assetTypeInfo)
		if assetTypeInfo then
			if not hasMultipleAttachments(assetTypeInfo) then
				local _, attachment = next(assetTypeInfo.Attachments)
				self.onClickAttachment(attachment)
			else
				self.multiAttachmentAsset = {
					[key] = assetTypeInfo,
				}
			end
		end
	end

	self.onClickAccessoryType = function(key)
		self.onClickAssetType(key, Constants.ASSET_TYPE_ATTACHMENT.Accessory[key])
	end

	self.onClickClothingType = function(key)
		self.onClickAssetType(key, Constants.ASSET_TYPE_ATTACHMENT.Clothing[key])
	end

	self.renderAttachmentSubList = function(order)
		local props = self.props
		local state = self.state

		local localization = props.Localization

		local key, info = next(state.multiAttachmentAsset)

		return Roact.createElement(LCERadioButtonList, {
			Title = key,
			Buttons = makeButtonList(localization, info.Attachments),
			OnClick = function(selectedKey)
				self.onClickAttachmentSubList(selectedKey, info)
			end,
			LayoutOrder = order,
		})
	end

	self.renderAssetTypeList = function(order)
		local props = self.props

		local theme = props.Stylizer
		local localization = props.Localization

		local orderIterator = LayoutOrderIterator.new()

		return Roact.createElement(Pane, {
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = order,
			Layout = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Spacing = theme.MainPadding,
		}, {
			AccessoryTypeList = Roact.createElement(LCERadioButtonList, {
				Title = localization:getText("AssetType", "Accessory"),
				Buttons = makeButtonList(localization, Constants.ASSET_TYPE_ATTACHMENT.Accessory),
				OnClick = self.onClickAccessoryType,
				LayoutOrder = order + orderIterator:getNextOrder(),
			}),

			ClothingTypeList = Roact.createElement(LCERadioButtonList, {
				Title = localization:getText("AssetType", "Clothing"),
				Buttons = makeButtonList(localization, Constants.ASSET_TYPE_ATTACHMENT.Clothing),
				OnClick = self.onClickClothingType,
				LayoutOrder = order + orderIterator:getNextOrder(),
			}),
		})
	end
end

function AssetTypeScreen:getContentToRender()
	local state = self.state

	local multiAttachmentAsset = state.multiAttachmentAsset
	if multiAttachmentAsset then
		return self.renderAttachmentSubList
	else
		return self.renderAssetTypeList
	end
end

function AssetTypeScreen:render()
	local props = self.props

	local localization = props.Localization
	local renderContent = self:getContentToRender()

	return Roact.createElement(Pane, {
		Size = UDim2.new(1, 0, 1, 0),
		Style = "Box",
	}, {
		Screen = Roact.createElement(FlowScreenLayout, {
			Title = localization:getText("AssetType", "AssetType"),
			PromptText = localization:getText("AssetType", "Prompt"),
			NextButtonText = localization:getText("Flow", "Next"),
			BackButtonText = localization:getText("Flow", "Back"),
			NextButtonEnabled = true,
			BackButtonEnabled = true,
			HasBackButton = true,
			GoToNext = self.onNext,
			GoToPrevious = self.onBack,
			RenderContent = renderContent,
		})
	})
end

ContextServices.mapToProps(AssetTypeScreen,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	EditingItemContext = EditingItemContext,
})

local function mapDispatchToProps(dispatch)
	return {
		SetAccessoryTypeInfo = function(info)
			dispatch(SetAccessoryTypeInfo(info))
		end
	}
end

return RoactRodux.connect(nil, mapDispatchToProps)(AssetTypeScreen)