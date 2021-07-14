--[[
	This component is responsible for configging the asset's access field.

	Props:
	onDropDownSelect, function, will return current selected item if selected.
]]
local FFlagUGCGroupUploads = game:GetFastFlag("UGCGroupUploads")

local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local Util = Plugin.Core.Util
local ContextHelper = require(Util.ContextHelper)
local ContextGetter =require (Util.ContextGetter)
local Constants = require(Util.Constants)
local AssetConfigConstants = require(Util.AssetConfigConstants)
local getUserId = require(Util.getUserId)
local AssetConfigUtil = require(Util.AssetConfigUtil)

local DropdownMenu = require(Plugin.Core.Components.DropdownMenu)

local Requests = Plugin.Core.Networking.Requests
local GetAssetConfigManageableGroupsRequest = require(Requests.GetAssetConfigManageableGroupsRequest)
local GetAvatarAssetsValidGroupsRequest = require(Requests.GetAvatarAssetsValidGroupsRequest)
local GetGroupMetadata = require(Plugin.Core.Thunks.GetGroupMetadata)

local ConfigTypes = require(Plugin.Core.Types.ConfigTypes)

local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local getNetwork = ContextGetter.getNetwork

local ConfigAccess = Roact.PureComponent:extend("ConfigAccess")

local TITLE_HEIGHT = 40

local DROP_DOWN_WIDTH = 220
local DORP_DOWN_HEIGHT = 38

function ConfigAccess:init(props)
	self.allowOwnerEdit = props.screenFlowType == AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW
end

function ConfigAccess:didMount()
	-- Initial request
	if FFlagUGCGroupUploads then
		if AssetConfigUtil.isCatalogAsset(self.props.assetTypeEnum) then
			self.props.getAvatarAssetsValidGroups(getNetwork(self), self.props.assetTypeEnum)
		else
			self.props.getManageableGroups(getNetwork(self))
		end
	else
		self.props.getManageableGroups(getNetwork(self))
	end
end

function ConfigAccess:render()
	return withTheme(function(theme)
		return withLocalization(function(_, localizedContent)
			local props = self.props
			local state = self.state

			local Title = props.Title
			local LayoutOrder = props.LayoutOrder
			local TotalHeight = props.TotalHeight
			local owner = props.owner or {}

			-- We have a bug, on here: https://developer.roblox.com/api-reference/enum/CreatorType
			-- User is 0, howerver in source code, User is 1.
			-- TODO: Notice UX to change the website.
			local ownerIndex = (owner.typeId or 1)
			if FFlagUGCGroupUploads then
				local groups = AssetConfigUtil.isCatalogAsset(props.assetTypeEnum)
					and props.avatarAssetsValidGroups
					or props.manageableGroups
				self.dropdownContent = AssetConfigUtil.getOwnerDropDownContent(groups, localizedContent)
			else
				self.dropdownContent = AssetConfigUtil.getOwnerDropDownContent(props.manageableGroups, localizedContent)
			end

			local onDropDownSelect = props.onDropDownSelect

			local publishAssetTheme = theme.publishAsset

			local ownerName = ""
			if (not self.allowOwnerEdit) and owner.typeId then
				if owner.typeId == ConfigTypes.OWNER_TYPES.User then
					if owner.targetId ~= getUserId() then
						ownerName = owner.username
					else
						ownerName = localizedContent.AssetConfig.PublishAsset.Me
					end
				else -- If not owned by Me, then it's owned by a group.
					-- Load the groupName
					if props.assetGroupData then
						ownerName = props.assetGroupData.Name
					end
				end
			end

			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, TotalHeight),

				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.fromRGB(227, 227, 227),
				BorderSizePixel = 0,

				LayoutOrder = LayoutOrder
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
				}),

				Title = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, AssetConfigConstants.TITLE_GUTTER_WIDTH, 1, 0),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = Title,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextSize = Constants.FONT_SIZE_TITLE,
					TextColor3 = publishAssetTheme.titleTextColor,
					Font = Constants.FONT,


					LayoutOrder = 1,
				}),

				DropDown = self.allowOwnerEdit and Roact.createElement(DropdownMenu, {
					Size = UDim2.new(0, DROP_DOWN_WIDTH, 0, DORP_DOWN_HEIGHT),
					visibleDropDownCount = 5,
					selectedDropDownIndex = ownerIndex,

					fontSize = Constants.FONT_SIZE_LARGE,
					items = self.dropdownContent,
					onItemClicked = onDropDownSelect,

					LayoutOrder = 2,
				}),

				OwnerType = (not self.allowOwnerEdit) and Roact.createElement("TextLabel", {
					Size = UDim2.new(1, -AssetConfigConstants.TITLE_GUTTER_WIDTH, 0, Constants.FONT_SIZE_TITLE),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = ownerName,
					Font = Constants.FONT,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextSize = Constants.FONT_SIZE_TITLE,
					TextColor3 = publishAssetTheme.textColor,

					LayoutOrder = 2,
				}),
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	state = state or {}

	local assetGroupData = (props.owner and state[props.owner.targetId] and state[props.owner.targetId].groupMetadata) or props.assetGroupData
	local owner = (state.assetConfigData and state.assetConfigData.Creator) or props.owner

	return {
		assetTypeEnum = state.assetTypeEnum,
		screenFlowType = state.screenFlowType,
		manageableGroups = state.manageableGroups or {},
		avatarAssetsValidGroups = state.avatarAssetsValidGroups or {},
		assetGroupData = assetGroupData,
		owner = owner,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		getManageableGroups = function(networkInterface)
			dispatch(GetAssetConfigManageableGroupsRequest(networkInterface))
		end,
		getAvatarAssetsValidGroups = function(networkInterface, assetType)
			dispatch(GetAvatarAssetsValidGroupsRequest(networkInterface, assetType))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ConfigAccess)
