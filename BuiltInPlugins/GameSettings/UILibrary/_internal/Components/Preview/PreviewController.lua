--[[
	This component is used to render both mainPreview and TreeView.
	MainView can be modelPreview, soundPreview, scriptPreview, imagePreview, otherPreview and audioPlay.
	Note soundPreview and audioPlay are different here. Sound preview is uesed to preview sound object comes with
	the model, audioPlay is the audioPlayer we made for the audio asset. Which actually supports play, pause.

	Required Props:
	Width = number,

	CurrentPreview = Instance, this is the instance that is currently displayed in the preview.
	PreviewModel = Instance, this is the top level asset that will be displayed in the InstanceTreeView
	AssetPreviewType = AssetType.TYPES, custom category that will inform which preview will be displayed.
	AssetId = number,
	PutTreeViewOnBottom = boolean, this determines whether the TreeView will be displayed on the right or bottom.

	OnTreeItemClicked = callback, which sets the preview to show the new Tree Item, the callback takes 1 parameter of type instance.
	OnModelPreviewFrameEntered = callback, this is a callback that disables the scrollbar
	OnModelPreviewFrameLeft = callback, this is a callback that re-enables teh scollbar

	LayoutOrder = number,
]]
local FFlagHideOneChildTreeviewButton = game:GetFastFlag("HideOneChildTreeviewButton")

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local ModelPreview = require(Library.Components.Preview.ModelPreview)
local ImagePreview = require(Library.Components.Preview.ImagePreview)
local ThumbnailIconPreview = require(Library.Components.Preview.ThumbnailIconPreview)
local TreeViewButton =  require(Library.Components.Preview.TreeViewButton)
local AssetType = require(Library.Utils.AssetType)
local AudioPreview = require(Library.Components.Preview.AudioPreview)
local VideoPreview = require(Library.Components.Preview.VideoPreview)

local TreeViewItem = require(Library.Components.Preview.InstanceTreeViewItem)
local TreeView = require(Library.Components.TreeView)

local LoadingIndicator = require(Library.Components.LoadingIndicator)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Urls = require(Library.Utils.Urls)

local TREEVIEW_WIDTH = 242
local PREVIEW_HEIGHT = 242
local TREEVIEW_BOTTOM_HEIGHT = 120
local MAINVIEW_BUTTONS_X_OFFSET = -7
local MAINVIEW_BUTTONS_Y_OFFSET = -7

local MODAL_MIN_WIDTH = 235

local PreviewController = Roact.PureComponent:extend("PreviewController")

local function getImage(instance)
	if typeof(instance) ~= "Instance" then
		return nil
	end

	if instance:IsA("Decal") or instance:IsA("Texture") then
		return instance.Texture
	elseif instance:IsA("Sky") then
		return instance.SkyboxFt
	else
		return instance.Image
	end
end

local function getImageScaleType(instance)
	if typeof(instance) ~= "Instance" then
		return Enum.ScaleType.Fit
	end
	if instance:IsA("Sky") then
		return Enum.ScaleType.Crop
	else
		return Enum.ScaleType.Fit
	end
end

function PreviewController:createTreeView(previewModel, size)
	return withTheme(function(theme)
		local onTreeviewEntered = self.onTreeviewEntered
		local onTreeviewLeft = self.onTreeviewLeft

		local dataTree = previewModel

		return Roact.createElement("ImageButton", {
			Size = size,

			BackgroundTransparency = 0,
			BackgroundColor3 = theme.instanceTreeView.background,
			BorderSizePixel = 0,
			AutoButtonColor = false,

			[Roact.Event.MouseEnter] = onTreeviewEntered,
			[Roact.Event.MouseLeave] = onTreeviewLeft,

			LayoutOrder = 2
		},{
			TreeViewFrame = Roact.createElement(TreeView, {
				dataTree = dataTree,
				onSelectionChanged = self.onTreeItemClicked,

				createFlatList = true,

				getChildren = function(instance)
					return instance:GetChildren()
				end,

				renderElement = function(properties)
					return Roact.createElement(TreeViewItem, properties)
				end,
			})
		})
	end)
end

function PreviewController:init(props)
	self.state = {
		-- This controls the treeview and full screen button's status
		showTreeView = false,
	}

	self.inModelPreview = false
	self.inTreeview = false
	self.totalTimeSpent = 0
	self.cacheTime = 0

	self.onTreeviewStatusToggle = function(newStatus)
		self:setState({
			showTreeView = newStatus,
		})
	end

	self.onModelPreviewFrameEntered = function(...)
		self.props.OnModelPreviewFrameEntered(...)

		self.onPreviewStatusChange(true, self.inTreeview)
	end

	self.onModelPreviewFrameLeft = function(...)
		self.props.OnModelPreviewFrameLeft(...)

		self.onPreviewStatusChange(false, self.inTreeview)
	end

	self.onTreeviewEntered = function()
		self.onPreviewStatusChange(self.inModelPreview, true)
	end

	self.onTreeviewLeft = function()
		self.onPreviewStatusChange(self.inModelPreview, false)
	end

	self.onPreviewStatusChange = function(newModelStatus, newTreeStatus)
		if (not self.inModelPreview and not self.inTreeview) and
			(newModelStatus or newTreeStatus) then
			-- Time to start the timer
			self.cacheTime = os.clock()
		end

		if (not newModelStatus and not newTreeStatus) and
			(self.inModelPreview or self.inTreeview) then
			local currentTime = os.clock()
			local newTimeSpent = currentTime - self.cacheTime
			if newTimeSpent > 0 then
				self.totalTimeSpent = self.totalTimeSpent + math.floor(newTimeSpent * 1000)
			end
		end

		self.inModelPreview = newModelStatus
		self.inTreeview = newTreeStatus
	end

	self.onTreeItemClicked = function(instances)
		if instances[1] then
			self.props.OnTreeItemClicked(instances[1])
		end
	end
end

function PreviewController:render()
	local props = self.props
	local state = self.state

	local currentPreview = props.CurrentPreview
	local previewModel = props.PreviewModel
	local assetPreviewType = props.AssetPreviewType
	local assetId = props.AssetId
	local putTreeviewOnBottom = props.PutTreeviewOnBottom
	local width = props.Width
	local layoutOrder = props.LayoutOrder

	local isShowVideoPreview = AssetType:isVideo(assetPreviewType)
	local videoId
	if isShowVideoPreview then
		videoId = currentPreview.Video
	end

	local showTreeView = state.showTreeView
	local previewSize
	local treeViewSize
	local height
	if showTreeView then
		height = putTreeviewOnBottom and PREVIEW_HEIGHT + TREEVIEW_BOTTOM_HEIGHT or PREVIEW_HEIGHT
		previewSize = putTreeviewOnBottom and UDim2.new(1, 0, 0, PREVIEW_HEIGHT)
			or UDim2.new(1, -TREEVIEW_WIDTH, 0, PREVIEW_HEIGHT)
		treeViewSize = putTreeviewOnBottom and UDim2.new(1, 0, 0, TREEVIEW_BOTTOM_HEIGHT)
			or UDim2.new(0, TREEVIEW_WIDTH, 0, PREVIEW_HEIGHT)
	else
		height = PREVIEW_HEIGHT
		previewSize = UDim2.new(1, 0, 0, PREVIEW_HEIGHT)
		treeViewSize = UDim2.new()
	end

	local showTreeViewButton = (not AssetType:isPlugin(assetPreviewType))
	if FFlagHideOneChildTreeviewButton then
		local dataTree = previewModel
		local hasMultiplechildren = dataTree and (#dataTree:GetChildren() > 0) or false
		showTreeViewButton = showTreeViewButton and hasMultiplechildren
	end

	local onModelPreviewFrameEntered = self.onModelPreviewFrameEntered
	local onModelPreviewFrameLeft = self.onModelPreviewFrameLeft

	local THUMBNAIL_HEIGHT = PREVIEW_HEIGHT < MODAL_MIN_WIDTH and PREVIEW_HEIGHT or MODAL_MIN_WIDTH
	local showThumbnail = AssetType:isScript(assetPreviewType) or AssetType:isOtherType(assetPreviewType)

	local soundId
	if AssetType:isAudio(assetPreviewType) and currentPreview then
		-- It's wrong to get SoundId from currenttPreview, it should be previewModel.
		soundId = currentPreview.SoundId
	end

	local reportPlay = props.reportPlay
	local reportPause = props.reportPause

	local isShowAudioPreview = AssetType:isAudio(assetPreviewType)
	local mainViewButtonYOffset
	if isShowAudioPreview then
		mainViewButtonYOffset = 3
	else
		mainViewButtonYOffset = MAINVIEW_BUTTONS_Y_OFFSET
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, width, 0, height),

		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		LayoutOrder = layoutOrder,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = putTreeviewOnBottom and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		MainView = Roact.createElement("Frame", {
			Size = previewSize,

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			LayoutOrder = 1,
		}, {
			PreviewLoading = AssetType:isLoading(assetPreviewType) and Roact.createElement(LoadingIndicator,{
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			}),

			ModelPreview = AssetType:isModel(assetPreviewType) and Roact.createElement(ModelPreview, {
					TargetModel = currentPreview,

					OnModelPreviewFrameEntered = onModelPreviewFrameEntered,
					OnModelPreviewFrameLeft = onModelPreviewFrameLeft,
			}),

			ImagePreview = AssetType:isImage(assetPreviewType) and Roact.createElement(ImagePreview, {
				ImageContent = getImage(currentPreview),
				ScaleType = getImageScaleType(currentPreview),
			}),

			AudioPreview = isShowAudioPreview and Roact.createElement(AudioPreview, {
				SoundId = soundId or Urls.constructAssetIdString(assetId),
				AssetId = assetId,
				ShowTreeView = showTreeView,
				ReportPlay = reportPlay,
				ReportPause = reportPause,
			}),

			VideoPreview = isShowVideoPreview and Roact.createElement(VideoPreview, {
				VideoId = videoId or Urls.constructAssetIdString(assetId),
				ShowTreeView = showTreeView,
			}),

			PluginPreview = AssetType:isPlugin(assetPreviewType) and Roact.createElement("ImageLabel", {
				Image = Urls.constructAssetThumbnailUrl(assetId, 420, 420),
				Size = UDim2.new(0,THUMBNAIL_HEIGHT,0,THUMBNAIL_HEIGHT),
				Position = UDim2.new(0.5,0,0,0),
				AnchorPoint = Vector2.new(0.5,0),
			}),

			-- Let the script and other share the same component for now
			ThumbnailIconPreview = showThumbnail and Roact.createElement(ThumbnailIconPreview, {
				TargetInstance = currentPreview,
				AssetId = assetId,
				ElementName = currentPreview.Name,
			}),

			TreeViewButton = showTreeViewButton and Roact.createElement(TreeViewButton, {
				Position = UDim2.new(1, MAINVIEW_BUTTONS_X_OFFSET, 1, mainViewButtonYOffset),
				ZIndex = 2,

				ShowTreeView = state.showTreeView,
				OnTreeviewStatusToggle = self.onTreeviewStatusToggle,
			})
		}),

		TreeView = showTreeView and self:createTreeView(previewModel, treeViewSize)
	})
end

return PreviewController
