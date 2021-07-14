--[[
	This component is responsible for creating an clickable button for Overriding assets.
	There will be a thumbnail and asset title for the button.

	Necessary Props:
		Size, UDim2
		assetTypeEnum, Enum, a enum type that contains the name and value of the assetType.
		resultsArray, an array of tables, contains the data for overriding assets.
		onOverrideAssetSelected, function, will be called when a asset is selected.
		getOverrideAssets, function, funtion used to reuqest more asset data for override asset.

	Optional Props:
		LayoutOrder, number, will be used by the layout to change the component's position.
]]

local FFlagToolboxUseInfiniteScroller = game:DefineFastFlag("ToolboxUseInfiniteScroller", false)
local FFlagToolboxReplaceUILibraryComponentsPt3 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt3")

local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Framework = require(Libs.Framework)
local Tooltip = Framework.UI.Tooltip

local Requests = Plugin.Core.Networking.Requests
local MakeChangeRequest = require(Requests.MakeChangeRequest)

local Util = Plugin.Core.Util
local ContextHelper = require(Util.ContextHelper)
local Constants = require(Util.Constants)
local Urls = require(Util.Urls)
local Images = require(Util.Images)
local Colors = require(Util.Colors)
local AssetConfigConstants = require(Util.AssetConfigConstants)

local DEPRECATED_InfiniteScrollingFrame = require(Plugin.Core.Components.InfiniteScrollingFrame)
local InfiniteScrollingFrame = Framework.UI.InfiniteScrollingFrame

local ContextServices = Framework.ContextServices
local withTheme = ContextHelper.withTheme

local OverrideAssetView = Roact.PureComponent:extend("OverrideAssetView")

local TITLE_HEIGHT = 48
local CELL_PADDING_WIDTH = 24
local CELL_PADDING_HEIGHT = 26
local CELL_SIZE_WIDTH = 150
local CELL_SIZE_HEIGHT = 198
local MAX_CELL = 4
local PADDING = 12
local CHECK_ICON_OFFSET = 4
local CHECK_ICON_SIZE = 28

function OverrideAssetView:init(props)
	self.state = {
		selectedAssetId = 0,
		pageIndex = 1,
		layoutContentSize = Vector2.new(),
	}

	self.newAssetInfo = {
		assetTypeEnum = props.assetTypeEnum,
		instances = props.instances
	}

	self.layouterRef = Roact.createRef()

	-- When this component updates from going to a new page, sometimes render runs before layout's content size
	-- actually updates, causing elements in the frame to not be reachable. We do this here to basically force the
	-- update again after the size has actually changed.
	self.onLayoutContentSizeChange = function(rbx)
		self:setState({
			layoutContentSize = rbx.AbsoluteContentSize,
		})
	end

	self.onAssetActivated = function(asset)
		local assetId = asset.Asset.Id

		if assetId == self.state.selectedAssetId then
			return
		end

		-- For clicking the apply button.
		props.onOverrideAssetSelected(assetId)

		self.props.makeChangeRequest("OverrideAssetId", self.state.selectedAssetId, assetId)

		-- For UI
		self:setState({
			selectedAssetId = assetId
		})
	end

	self.requestOverrideAsset = function()
		-- TODO STM-352: Apparently FFlagToolboxUseInfiniteScroller does not work with this code.
		props.getOverrideAssets(self.state.pageIndex)
		self:setState({
			pageIndex = self.state.pageIndex + 1,
		})
	end

	self.DEPRECATED_requestOverrideAsset = function(targetPage)
		props.getOverrideAssets(targetPage)
		if self.state.pageIndex ~= targetPage then
			self:setState({
				pageIndex = targetPage
			})
		end
	end
end

function OverrideAssetView:createAssets(resultsArray, theme)
	local assetConfigTheme = theme.assetConfig

	local itemList = {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, PADDING),
			PaddingLeft = UDim.new(0, 1), -- Make sure we have enough space on each side while don't clip the edges.
			PaddingRight = UDim.new(0, 1),
			PaddingTop = UDim.new(0, PADDING),
		}),

		UIGridLayout = Roact.createElement("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			CellPadding = UDim2.new(0, CELL_PADDING_WIDTH, 0, CELL_PADDING_HEIGHT),
			CellSize = UDim2.new(0, CELL_SIZE_WIDTH, 0, CELL_SIZE_HEIGHT),
			FillDirectionMaxCells = MAX_CELL,
			StartCorner = Enum.StartCorner.TopLeft,

			[Roact.Ref] = self.layouterRef,
			[Roact.Change.AbsoluteContentSize] = self.onLayoutContentSizeChange,
		}),
	}

	local filterID = self.props.filterID

	-- Basically, we need only Id and name
	local selectedAssetId = self.state.selectedAssetId
	for index, asset in pairs(resultsArray) do
		local assetId = asset.Asset.Id
		local thumbnailUrl = Urls.constructAssetThumbnailUrl(assetId,
			Constants.THUMBNAIL_SIZE_LARGE,
			Constants.THUMBNAIL_SIZE_LARGE)
		local selected = selectedAssetId == assetId

		local inFilter = true
		inFilter = filterID == "" or tostring(assetId):find(filterID, 1, true)

		itemList[assetId] = inFilter and Roact.createElement("TextButton", {
			Size = AssetConfigConstants.OverrideAssetItemSize,

			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Text = "",
			Font = Constants.FONT,
			TextSize = Constants.FONT_SIZE_MEDIUM,

			[Roact.Event.Activated] = function(rbx)
				self.onAssetActivated(asset)
			end,

			LayoutOrder = index,
		}, {
			UIListLayout = Roact.createElement("UIListLayout"),

			Border = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -TITLE_HEIGHT),

				BackgroundTransparency = 0,
				BackgroundColor3 = Colors.WHITE, -- need to match the background to fake transparency
				BorderSizePixel = 1,
				BorderColor3 = selected and Colors.BLUE_PRIMARY or Colors.GRAY_3,

				LayoutOrder = 1,
			}, {
				ThumbNail = Roact.createElement("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),

					BorderSizePixel = 1,
					BackgroundTransparency = 1,
					Image = thumbnailUrl,
				}),

				CheckedIcon = selected and Roact.createElement("ImageLabel", {
					Position = UDim2.new(0, CHECK_ICON_OFFSET, 0, CHECK_ICON_OFFSET),
					Size = UDim2.new(0, CHECK_ICON_SIZE, 0, CHECK_ICON_SIZE),

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Image = Images.SELECTED_CHECK,
					ImageColor3 = Colors.BLUE_PRIMARY
				}),

				-- The tooltip needs to be attached to the icon and text separately to layout correctly
				Tooltip = Roact.createElement(Tooltip, {
					Text = asset.Asset.Name,
				}) or nil,
			}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),

				Text = asset.Asset.Name,
				Font = Constants.FONT,
				TextColor3 = assetConfigTheme.textColor,
				TextSize = Constants.FONT_SIZE_MEDIUM,
				TextTruncate = Enum.TextTruncate.AtEnd,

				BorderSizePixel = 0,
				BackgroundTransparency = 1,

				LayoutOrder = 2,
			}, {
				-- The tooltip needs to be attached to the icon and text separately to layout correctly
				Tooltip = Roact.createElement(Tooltip, {
					Text = asset.Asset.Name,
				}) or nil,
			}),
		})
	end

	return itemList
end

function OverrideAssetView:render()
	if FFlagToolboxReplaceUILibraryComponentsPt3 then
		return self:renderContent()
	else
		return withTheme(function(theme)
			return self:renderContent(theme)
		end)
	end
end

function OverrideAssetView:renderContent(theme)
	local props = self.props
	local state = self.state
	if FFlagToolboxReplaceUILibraryComponentsPt3 then
		theme = self.props.Stylizer
	end

	local Size = props.Size

	local itemList = self:createAssets(props.resultsArray or {}, theme)
	local publishAssetTheme = theme.publishAsset

	local layouterRef = self.layouterRef

	if FFlagToolboxUseInfiniteScroller then
		return Roact.createElement(InfiniteScrollingFrame, {
			LoadNext = self.requestOverrideAsset,
			LayoutOrder = props.LayoutOrder,
			Size = Size,
		}, itemList)
	else
		return Roact.createElement(DEPRECATED_InfiniteScrollingFrame, {
			Size = Size,

			BackgroundColor3 = publishAssetTheme.backgroundColor,
			layouterRef = layouterRef,

			nextPageFunc = self.DEPRECATED_requestOverrideAsset,

			LayoutOrder = props.LayoutOrder,
		}, itemList)
	end
end

local function mapDispatchToProps(dispatch)
	return {
		makeChangeRequest = function(setting, currentValue, newValue)
			dispatch(MakeChangeRequest(setting, currentValue, newValue))
		end,
	}
end

if FFlagToolboxReplaceUILibraryComponentsPt3 then
	ContextServices.mapToProps(OverrideAssetView, {
		Stylizer = ContextServices.Stylizer,
	})
end

return RoactRodux.connect(nil, mapDispatchToProps)(OverrideAssetView)