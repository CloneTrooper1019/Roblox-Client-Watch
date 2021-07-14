-- Deprecated - remove this folder with removal of FFlagToolboxUseDevFrameworkAssetPreview and FFlagAssetManagerUseDevFrameworkAssetPreview
--[[
	AssetPreview component is responsible for manageing the models will be displaying on the
	ViewPortFrame.
	Models, detail information regarding the asset should be coming from the parent. Asnyc reqest for getting
	the asset should also be done in the parent.

	Necessary property:
		Position = UDim2, the position of Asset Preview with respect to it's parent.
		AnchorPoint = Vector2, used to center Asset Preview with respect to it's parent.
		MaxPreviewWidth = number, the maximum width allowed for this component.
		MaxPreviewHeight = number, the maximum height allowed for this component.

		AssetData = table, a table contains asset data.
		CurrentPreview = asset , the current asset displayed in AssetPreview both for 3D view and Tree View.

		ActionBarText = string, the text shown in the large button of the ActionBar.
		TryInsert = callback, this determines the behavior of the large button in the ActionBar.

		OnFavoritedActivated = callback, this callback is invoked when the favorites button is clicked for the asset.
		FavoriteCounts = number, the number of favorites that this asset has.
		Favorited = boolean, whether or not the current user has this asset favorited.

		TryCreateContextMenu = callback, that creates a context menu in the triple dot (...) of the ActionBar.
		OnTreeItemClicked = callback, that determines the behavior of when an item is clicked in the TreeView
			The TreeView is a part of the PreviewController.

	Optional property:
		InstallDisabled = boolean, used in PluginPurchaseFlow to disable the ActionBar install button
			when the plugin is already installed.
		PurchaseFlow = component, component which is the start of the PluginPurhaseFlow
		SuccessDialog = component, success dialog shown at the end of the PluginPurchaseFlow
		ShowRobuxIcon = boolean, to determine whether or not the Robux Icon should be shown in the ActionBar.
		ShowInstallationBar = boolean, determines if the installation bar should be shown, this is used in PluginPurchaseFlow
		LoadingBarText = string, the text that should be displayed with the loading/installation bar.

		HasRating = boolean, determines whether or not Voting and Favorites should be displayed.
		Voting = table, table of voting information structed as:
			{
				UpVotes = number,
				DownVotes = number,
			}
		OnVoteUp = callback, to be invoked when the vote up button is clicked in the Vote component.
		OnVoteDown = callback, to be invoked when the vote down button is clicked in the Vote component.

		SearchByCreator = callback, to search for asset in the current Marketplace category
			that are created by the same creator as current asset.

		ZIndex = num, used to override the zIndex depth of the base button.
]]

local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Favorites = require(Library.Components.Preview.Favorites)
local PreviewController = require(Library.Components.Preview.PreviewController)
local Vote = require(Library.Components.Preview.Vote)
local ActionBar = require(Library.Components.Preview.ActionBar)
local AssetDescription = require(Library.Components.Preview.AssetDescription)
local LoadingBar = require(Library.Components.LoadingBar)
local SearchLinkText = require(Library.Components.Preview.SearchLinkText)

local LayoutOrderIterator = require(Library.Utils.LayoutOrderIterator)
local GetTextSize = require(Library.Utils.GetTextSize)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local AssetType = require(Library.Utils.AssetType)

local AssetPreview = Roact.PureComponent:extend("AssetPreview")

-- TODO: Later, I will need to move all the unchanged numbers
-- into the constants.
local TITLE_HEIGHT = 18

local VERTICAL_PADDING = 10
local TOP_PADDING = 12
local BOTTOM_PADDING = 20

local VOTE_HEIGHT = 36

local ACTION_BAR_HEIGHT = 52
local INSTALLATION_BAR_SECTION_HEIGHT = 80
local INSTALLATION_BAR_SECTION_PADDING = 16
local INSTALLATION_BAR_HEIGHT = 6
local INSTALLATION_ANIMATION_TIME = 1.0 --seconds


-- Multiply minimum treeview width by 2 to get minimum threshold
-- When the asset preview is twice the minimum width, then we
-- can split the view in half to show the treeview on the right.
local TREEVIEW_ON_BOTTOM_WIDTH_THRESHOLD = 242 * 2

local function getGenreString(genreArray)
	local arraySize = #genreArray
	if arraySize == 0 then
		return "All"
	else
		return tostring(genreArray[1])
	end
end

function AssetPreview:init(props)
	self.state = {
		enableScroller = true,
		overrideEnableVoting = false,
	}

	self.assetSizeInited = false

	self.baseScrollRef = Roact.createRef()
	self.baseLayouterRef = Roact.createRef()

	self.assetBaseButtonRef = Roact.createRef()

	self.onModelPreviewFrameEntered = function()
		self:setState({
			enableScroller = false
		})
	end

	self.onModelPreviewFrameLeft = function()
		self:setState({
			enableScroller = true
		})
	end

	-- For first time setting the canvas size.
	self.onScrollContentSizeChange = function(rbx)
		local baseScroller = self.baseScrollRef.current
		local listLayouter = self.baseLayouterRef.current
		local absSize = listLayouter and listLayouter.AbsoluteContentSize or Vector2.new()
		if baseScroller and listLayouter then
			baseScroller.CanvasSize = UDim2.new(1, 0, 0, absSize.Y + BOTTOM_PADDING)
		end

		self:adjustAssetHeight()
	end

	self.adjustAssetHeight = function()
		-- Init the total height of asset preview component
		local listLayouter = self.baseLayouterRef.current
		local assetBaseButton = self.assetBaseButtonRef.current
		if assetBaseButton then
			local absSize = listLayouter and listLayouter.AbsoluteContentSize or Vector2.new()
			local assetHeight = math.min(absSize.Y + ACTION_BAR_HEIGHT + BOTTOM_PADDING, self.props.MaxPreviewHeight)
			assetBaseButton.Size = UDim2.new(0, self.props.MaxPreviewWidth, 0, assetHeight)
		end
	end

	self.searchByCreator = function()
		local assetData = props.AssetData
		local creator = assetData.Creator
		local creatorName = creator.Name
		if self.props.SearchByCreator then
			self.props.SearchByCreator(creatorName)
		end
	end
	if self.props.ClearPurchaseFlow then
		self.props.ClearPurchaseFlow(props.AssetData.Asset.Id)
	end
end

function AssetPreview:didMount()
	--[[
		FIXME (psewell)
		THIS IS A HACK! ScrollingFrames can sometimes render the scroll bar in the
		wrong place. Because of this, we have to hide the ScrollingFrame for a step
		so that the scroll bar appears in the right place when we make it visible.

		This is a temporary fix recommended by PlayerEx.
		There is a permanent fix on the way for this bug in C++.
		See https://jira.rbx.com/browse/CLIPLAYEREX-2494
	]]

	local scrollingFrame = self.baseScrollRef.current
	local baseButton = self.assetBaseButtonRef.current
	if scrollingFrame and baseButton then
		local stepConnection
		stepConnection = RunService.Heartbeat:Connect(function()
			scrollingFrame.Visible = true
			stepConnection:Disconnect()
		end)
	end
end

function AssetPreview:didUpdate()
	self:adjustAssetHeight()
end

function AssetPreview:render()
	return withTheme(function(theme)
		-- TODO: Time to tide up the properties passed from the asset.
		local props = self.props

		local assetPreviewTheme = theme.assetPreview

		local maxPreviewWidth = props.MaxPreviewWidth
		local maxPreviewHeight = props.MaxPreviewHeight

		local position = props.Position
		local anchorPoint = props.AnchorPoint

		local assetData = props.AssetData

		-- Data structure from the server
		local Asset = assetData.Asset
		local assetId = Asset.Id
		local assetName = Asset.Name or "Test Name"
		local detailDescription = Asset.Description or ""
		
		local created = Asset.Created
		local updated = Asset.Updated
		local assetGenres = Asset.AssetGenres

		local creator = assetData.Creator
		local creatorName = creator.Name

		local typeId = assetData.Asset.TypeId or Enum.AssetType.Model.Value

		local currentPreview = props.CurrentPreview
		local previewModel = props.PreviewModel

		local assetPreviewType
		if (typeId == Enum.AssetType.Plugin.Value) then
			assetPreviewType = AssetType:markAsPlugin()
		else
			assetPreviewType = AssetType:getAssetType(currentPreview)
		end

		local isPluginAsset, isPluginInstalled
		isPluginAsset = AssetType:isPlugin(assetPreviewType)
		isPluginInstalled = isPluginAsset and StudioService:IsPluginInstalled(assetId)

		local installDisabled = props.InstallDisabled
		local showRobuxIcon = props.ShowRobuxIcon or false
		local purchaseFlow = props.PurchaseFlow or nil
		local successDialog = props.SuccessDialog or nil
		local showInstallationBar = props.ShowInstallationBar or false

		local hasRating = props.HasRating or false

		local voting = props.Voting or {}
		local upVoteRate = 0
		if voting.UpVotes and voting.DownVotes then
			local totalVotes = voting.UpVotes + voting.DownVotes
			if totalVotes > 0 then
				upVoteRate = voting.UpVotes / totalVotes
			end
		end
		local rating = upVoteRate * 100

		local putTreeviewOnBottom = maxPreviewWidth <= TREEVIEW_ON_BOTTOM_WIDTH_THRESHOLD

		local assetSize = UDim2.new(0, maxPreviewWidth, 0, maxPreviewHeight)

		local zIndex = props.ZIndex or 0

		local onTreeItemClicked = props.OnTreeItemClicked

		local tryCreateContextMenu = props.TryCreateContextMenu

		local enableScroller = self.state.enableScroller

		local detailDescriptionWidth = props.MaxPreviewWidth - 4 * assetPreviewTheme.padding - 2
		local textSize = GetTextSize(detailDescription,
			assetPreviewTheme.textSizeLarge,
			assetPreviewTheme.font,
			Vector2.new(detailDescriptionWidth, 9000))
		local detailDescriptionHeight = textSize.y + VERTICAL_PADDING

		local layoutIndex = LayoutOrderIterator.new()

		local closeImageSize = UDim2.new(0, 28, 0, 28)

		return Roact.createElement("ImageButton", {
			Position = position,
			Size = assetSize,
			AnchorPoint = anchorPoint,

			ZIndex = zIndex,

			BackgroundTransparency = 0,
			BackgroundColor3 = assetPreviewTheme.background,
			AutoButtonColor = false,
			BorderSizePixel = 0,

			[Roact.Ref] = self.assetBaseButtonRef,
		},{
			CloseImage = Roact.createElement("ImageLabel", {
				Position = UDim2.new(1, 0, 0, 0),
				Size = closeImageSize,
				AnchorPoint = Vector2.new(0, 1),

				Image = assetPreviewTheme.images.deleteButton,
				BackgroundTransparency = 1,
			}),

			BaseScrollFrame = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, assetPreviewTheme.padding, 1, -ACTION_BAR_HEIGHT),
				Visible = true, --See comment in didMount

				ScrollBarThickness = 8,
				ScrollBarImageColor3 = theme.scrollingFrame.scrollbarImageColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				TopImage = assetPreviewTheme.images.scrollbarTopImage,
				MidImage = assetPreviewTheme.images.scrollbarMiddleImage,
				BottomImage = assetPreviewTheme.images.scrollbarBottomImage,
				ScrollingEnabled = enableScroller,

				[Roact.Ref] = self.baseScrollRef,
			},{
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, BOTTOM_PADDING),
					PaddingLeft = UDim.new(0, assetPreviewTheme.padding),
					PaddingRight = UDim.new(0, assetPreviewTheme.padding * 2),
					PaddingTop = UDim.new(0, TOP_PADDING),
				}),

				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, VERTICAL_PADDING),

					[Roact.Change.AbsoluteContentSize] = self.onScrollContentSizeChange,
					[Roact.Ref] = self.baseLayouterRef,
				}),

				AssetName = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),

					Text = assetName,
					Font = assetPreviewTheme.fontBold,
					TextSize = assetPreviewTheme.textSizeTitle,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = assetPreviewTheme.assetNameColor,
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,

					AutoLocalize = false,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				Rating = hasRating and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 12),

					LayoutOrder = layoutIndex:getNextOrder(),
				}, {
					VoteIcon = Roact.createElement("ImageLabel", {
						Size = UDim2.new(0, 16, 0, 16),
						BackgroundTransparency = 1,
						Image = assetPreviewTheme.images.thumbUpSmall,
					}),

					VoteText = Roact.createElement("TextLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 22, 0, 3),
						BackgroundTransparency = 1,

						Text = ("%d%%"):format(rating),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = assetPreviewTheme.textSizeMedium,
						Font = assetPreviewTheme.Font,
						TextColor3 = theme.assetPreview.vote.textColor,

						LayoutOrder = 1,
					}),
				}),

				PreviewController = Roact.createElement(PreviewController, {
					Width = assetPreviewTheme.padding * 2,

					CurrentPreview = currentPreview,
					PreviewModel = previewModel,
					AssetPreviewType = assetPreviewType,
					AssetId = assetId,
					PutTreeviewOnBottom = putTreeviewOnBottom,

					OnTreeItemClicked = onTreeItemClicked,
					OnModelPreviewFrameEntered = self.onModelPreviewFrameEntered,
					OnModelPreviewFrameLeft = self.onModelPreviewFrameLeft,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				LoadingIndicator = showInstallationBar and Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, INSTALLATION_BAR_SECTION_HEIGHT),
					BackgroundTransparency = 1,
					LayoutOrder = layoutIndex:getNextOrder(),
				}, {
					UIPadding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, 0),
						PaddingLeft = UDim.new(0, INSTALLATION_BAR_SECTION_PADDING),
						PaddingRight = UDim.new(0, INSTALLATION_BAR_SECTION_PADDING),
						PaddingTop = UDim.new(0, (INSTALLATION_BAR_SECTION_HEIGHT * 0.5) + 10),
					}),

					LoadingBar =  Roact.createElement(LoadingBar, {
						LoadingText = self.props.LoadingBarText,
						Size = UDim2.new(1, 0, 0, INSTALLATION_BAR_HEIGHT),
						HoldPercent = 0.92,
						LoadingTime = INSTALLATION_ANIMATION_TIME,
						InstallationFinished = isPluginInstalled,
					}),
				}),

				Favorites =  Roact.createElement(Favorites, {
					Size = UDim2.new(1, 0, 0, 20),

					FavoriteCounts = self.props.FavoriteCounts,
					Favorited = self.props.Favorited,

					OnActivated = self.props.OnFavoritedActivated,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				DetailDescription = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, detailDescriptionHeight),

					BackgroundTransparency = 1,
					TextWrapped = true,

					Text = detailDescription,
					TextSize = assetPreviewTheme.textSizeLarge,
					Font = assetPreviewTheme.font,
					TextColor3 = assetPreviewTheme.descriptionTextColor,
					TextXAlignment = Enum.TextXAlignment.Left,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				Vote =  hasRating and Roact.createElement(Vote, {
					Size = UDim2.new(1, 0, 0, VOTE_HEIGHT),

					Voting = voting,
					AssetId = assetId,

					OnVoteUpButtonActivated = props.OnVoteUp,
					OnVoteDownButtonActivated = props.OnVoteDown,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				Developer = Roact.createElement(AssetDescription, {
					LeftContent = "Creator",
					RightContent = "",

					LayoutOrder = layoutIndex:getNextOrder(),
				}, {
					LinkText = Roact.createElement(SearchLinkText, {
						Text = creatorName,
						Position = UDim2.fromScale(1, 0.5),
						AnchorPoint = Vector2.new(1, 0.5),
						OnClick = self.searchByCreator,
					})
				}),

				Category = Roact.createElement(AssetDescription, {
					LeftContent = "Genre",
					RightContent = getGenreString(assetGenres),

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				Created = Roact.createElement(AssetDescription, {
					LeftContent = "Created",
					RightContent = created,

					LayoutOrder = layoutIndex:getNextOrder(),
				}),

				Updated = Roact.createElement(AssetDescription, {
					LeftContent = "Last Updated",
					RightContent = updated,
					HideSeparator = true,

					LayoutOrder = layoutIndex:getNextOrder(),
				})
			}),

			ActionBar =  Roact.createElement(ActionBar, {
				Text = self.props.ActionBarText,
				Size = UDim2.new(1, 0, 0, ACTION_BAR_HEIGHT),
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				AssetId = assetId,

				Asset = Asset,
				TryInsert = self.props.TryInsert,
				TryCreateContextMenu = tryCreateContextMenu,
				InstallDisabled = installDisabled,
				ShowRobuxIcon = showRobuxIcon,
			}),

			PurchaseFlow = purchaseFlow,

			SuccessDialog = successDialog,
		})
	end)
end

return AssetPreview