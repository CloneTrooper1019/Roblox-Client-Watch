--[[
	This component is responsible for rendering available asset for override when publishing new asset.
	It contains a drop down menu, defualt to current user. And will show names for all the group the user can manage.
	On this page, there will also be a scrolling frame contains all the asset item that is clickable. Clicking any asset
	will select the asset, then clicking the "Apply" button will override it.

	Necesarry Props:
	Size, UDim2
	assetTypeEnum, Enum, assetTypeEnum that contains both the name and value of it.
	instances, array of instances, used to generate serialised instance data for uploading.
	onOverrideAssetSelected, function, call back function called when a asset is selected for overriding.

	Optional Props:
	LayoutOrder, number, will used by the layouter to override the position.
]]
local FFlagToolboxReplaceUILibraryComponentsPt2 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt2")

local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local UILibrary = require(Libs.UILibrary)

local AssetConfiguration = Plugin.Core.Components.AssetConfiguration
local OverrideAssetView = require(AssetConfiguration.OverrideAssetView)
local DropdownMenu = require(Plugin.Core.Components.DropdownMenu)

local Util = Plugin.Core.Util
local ContextHelper = require(Util.ContextHelper)
local ContextGetter = require(Util.ContextGetter)
local Constants = require(Util.Constants)
local AssetConfigUtil = require(Util.AssetConfigUtil)
local getUserId = require(Util.getUserId)
local PagedRequestCursor = require(Util.PagedRequestCursor)
local AssetConfigConstants = require(Util.AssetConfigConstants)

local TextInput
local RoundTextBox
if FFlagToolboxReplaceUILibraryComponentsPt2 then
	local Framework = require(Libs.Framework)
	TextInput = Framework.UI.TextInput
else
	RoundTextBox = UILibrary.Component.RoundTextBox
end

local withTheme = ContextHelper.withTheme
local withLocalization = ContextHelper.withLocalization

local getNetwork = ContextGetter.getNetwork

local Requests = Plugin.Core.Networking.Requests
local GetOverrideAssetRequest = require(Requests.GetOverrideAssetRequest)
local GetAssetConfigManageableGroupsRequest = require(Requests.GetAssetConfigManageableGroupsRequest)

local UpdateAssetConfigStore = require(Plugin.Core.Actions.UpdateAssetConfigStore)

local OverrideAsset = Roact.PureComponent:extend("OverrideAsset")

local TITLE_HEIGHT = 30
local PADDING = 20
local DROPDOWN_WIDTH = 336
local DROPDOWN_HEIGHT = 40
local FILTER_HEIGHT = 90
local MAX_COUNT = 10
local TOOL_TIP_HEIGHT = 20

function OverrideAsset:init(props)
	self.dropdownContent = {
		{name = "Me", creatorType = "User", creatorId = getUserId()}
	}
	self.groupAdded = false

	self.state = {
		selectIndex = 1,
		selectItem = self.dropdownContent[1],
		filterID = "",
	}

	self.onFilterIDChanged = function(id)
		self:setState({
			filterID = id,
		})
	end

	self.onDropDownSelect = function(index)
		local item = self.dropdownContent[index]
		-- We supported override plugin only after this change.
		local overrideCursor = ""
		self.props.updateStore({
			fetchedAll = false,
			loadingPage = 0,
			overrideCursor = overrideCursor,
		})

		self.props.getOverrideAssets(getNetwork(self), self.props.assetTypeEnum, item.creatorType, item.creatorId, 1)
		self:setState({
			selectIndex = index,
			selectItem = item,
		})
	end

	self.getOverrideAssetsFunc = function(targetPage)
		local selectItem = self.state.selectItem
		self.props.getOverrideAssets(getNetwork(self), self.props.assetTypeEnum, selectItem.creatorType, selectItem.creatorId, targetPage)
	end
end

function OverrideAsset:didMount()
	-- Initial request
	local defaultSelect = self.dropdownContent[1]
	self.props.getOverrideAssets(
		getNetwork(self),
		self.props.assetTypeEnum,
		defaultSelect.creatorType,
		defaultSelect.creatorId,
		1
	)
	self.props.getManageableGroups(getNetwork(self))
end


function OverrideAsset:render()
	return withTheme(function(theme)
		return withLocalization(function(_, localizedContent)
			local props = self.props
			local state = self.state
			local assetConfigTheme = theme.assetConfig

			local LayoutOrder = props.LayoutOrder
			local Size = props.Size

			local assetTypeEnum = props.assetTypeEnum
			local instances = props.instances
			local onOverrideAssetSelected = props.onOverrideAssetSelected

			local resultsArray = props.resultsArray

			local selectIndex = state.selectIndex

			self.dropdownContent = AssetConfigUtil.getOwnerDropDownContent(props.manageableGroups, localizedContent)

			local useNewAnimFlow = assetTypeEnum == Enum.AssetType.Animation
			local isDownloadFlow = useNewAnimFlow and AssetConfigConstants.FLOW_TYPE.DOWNLOAD_FLOW == props.screenFlowType

			local textboxText = state.filterID
			local textOverMaxCount = false
			if FFlagToolboxReplaceUILibraryComponentsPt2 and textboxText then
				local textLength = utf8.len(textboxText)
				textOverMaxCount = textLength > MAX_COUNT
			end

			return Roact.createElement("Frame", {
				Size = Size,

				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				LayoutOrder = LayoutOrder
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 46),
					PaddingLeft = UDim.new(0, 24),
					PaddingRight = UDim.new(0, 24),
					PaddingTop = UDim.new(0, 46),
				}),

				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 20),
				}),

				Title = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = isDownloadFlow and localizedContent.AssetConfig.Import.Title or localizedContent.AssetConfig.Override.Title,
					Font = Constants.FONT,
					TextSize = Constants.FONT_SIZE_LARGE,
					TextColor3 = assetConfigTheme.textColor,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,

					LayoutOrder = 1,
				}),

				DropdownAndAnimationIdContainer = useNewAnimFlow and Roact.createElement("Frame", {
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -PADDING, 0, DROPDOWN_HEIGHT),
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, PADDING),
					}),

					DropdownMenu = Roact.createElement(DropdownMenu, {
						Size = UDim2.new(0, DROPDOWN_WIDTH, 0, DROPDOWN_HEIGHT),

						selectedDropDownIndex = selectIndex,
						rowHeight = DROPDOWN_HEIGHT,

						items = self.dropdownContent,
						onItemClicked = self.onDropDownSelect,

						LayoutOrder = 1,
					}),

					AnimationIdFilter = (not isDownloadFlow) and Roact.createElement("Frame", {
						Size = UDim2.new(1, -DROPDOWN_WIDTH, 0, FILTER_HEIGHT),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 2,
					}, {
						TextField = FFlagToolboxReplaceUILibraryComponentsPt2 and Roact.createElement(TextInput, {
							OnTextChanged = self.onFilterIDChanged,
							PlaceholderText = localizedContent.AssetConfig.Override.FilterID,
							Size = UDim2.new(1, -AssetConfigConstants.TITLE_GUTTER_WIDTH, 0, FILTER_HEIGHT - TITLE_HEIGHT - TOOL_TIP_HEIGHT),
							Style = textOverMaxCount and "FilledRoundedRedBorder" or "FilledRoundedBorder",
							Text = textboxText,
						})
						or Roact.createElement(RoundTextBox, {
							Active = true,
							ErrorMessage = nil,
							MaxLength = MAX_COUNT,
							Text = state.filterID,
							PlaceholderText = localizedContent.AssetConfig.Override.FilterID,
							Font = Constants.FONT,
							TextSize = Constants.FONT_SIZE_LARGE,
							Height = FILTER_HEIGHT - TITLE_HEIGHT - TOOL_TIP_HEIGHT,
							WidthOffset = -AssetConfigConstants.TITLE_GUTTER_WIDTH,
							SetText = self.onFilterIDChanged,
							ShowToolTip = false,
						})
					}),
				}),

				DropdownMenu = not useNewAnimFlow and Roact.createElement(DropdownMenu, {
					Size = UDim2.new(0, 336, 0, 40),

					selectedDropDownIndex = selectIndex,
					rowHeight = 40,

					items = self.dropdownContent,
					onItemClicked = self.onDropDownSelect,

					LayoutOrder = 2,
				}),

				ScrollingItems = Roact.createElement(OverrideAssetView, {
					Size = UDim2.new(1, 0, 1, - TITLE_HEIGHT - 40),

					assetTypeEnum = assetTypeEnum,
					instances = instances,
					resultsArray = resultsArray,
					onOverrideAssetSelected = onOverrideAssetSelected,
					getOverrideAssets = self.getOverrideAssetsFunc,
					filterID = state.filterID,

					LayoutOrder = 3,
				})
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	state = state or {}

	local stateToProps = {
		totalResults = state.totalResults,
		resultsArray = state.resultsArray,
		manageableGroups = state.manageableGroups or {},
		assetTypeEnum = state.assetTypeEnum,
	}

	stateToProps["screenFlowType"] = state.screenFlowType

	return stateToProps
end

local function mapDispatchToProps(dispatch)
	return {
		getOverrideAssets = function(networkInterface, assetTypeEnum, creatorType, creatorId, targetPage)
			dispatch(GetOverrideAssetRequest(networkInterface, assetTypeEnum, creatorType, creatorId, targetPage))
		end,

		getManageableGroups = function(networkInterface)
			dispatch(GetAssetConfigManageableGroupsRequest(networkInterface))
		end,

		updateStore = function(storeData)
			dispatch(UpdateAssetConfigStore(storeData))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(OverrideAsset)
