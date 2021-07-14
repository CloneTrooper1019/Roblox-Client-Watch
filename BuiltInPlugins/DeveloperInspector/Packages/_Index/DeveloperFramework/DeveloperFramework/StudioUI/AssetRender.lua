--[[
	A visual, interactive representation of any Asset.
	E.g. for models, an interactive 3D view.
	E.g. for videos, a video player.

	Required Props:
		table AssetData: The asset to preview.
		number Width: The width the component will occupy in pixels - this is required in order to
			determine whether the tree view should display horizontally or vertically.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Instance AssetInstance: The Instance of the asset to preview.
		callback OnMouseEnter: called on MouseEnter - useful to delegate mouse scroll input to this component.
		callback OnMouseLeave: called on MouseLeave - useful to delegate mouse scroll input to this component.
		boolean DisableTreeView: Disallow using the TreeView to inspect the asset's children.
			Hides the tree view toggle button.
		number LayoutOrder: LayoutOrder of the component.
		table Padding: Specific padding values for Top, Bottom, Left, and Right.
		table Margin: Specific margin values for Top, Bottom, Left, and Right.
		UDim2 Position: The position of this component.
		callback OnPlaySound: Called when a Sound plays.
		callback OnPauseSound: Called when a Sound plays.
		callback OnPlayVideo: Called when a Video plays.
		callback OnPauseVideo: Called when a Video plays.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local AssetRenderUtil = Util.AssetRenderUtil
local AssetRenderType = AssetRenderUtil.AssetRenderType
local Cryo = Util.Cryo

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local UI = require(Framework.UI)
local Button = UI.Button
local Container = UI.Container
local HoverArea = UI.HoverArea
local LoadingIndicator = UI.LoadingIndicator
local InstanceTreeView = UI.InstanceTreeView

local AudioPlayer = require(Framework.StudioUI.AudioPlayer)
local VideoPlayer = require(Framework.StudioUI.VideoPlayer)
local AssetRenderImage = require(Framework.StudioUI.AssetRenderImage)
local AssetRenderModel = require(Framework.StudioUI.AssetRenderModel)
local AssetRenderThumbnail = require(Framework.StudioUI.AssetRenderThumbnail)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local AssetRender = Roact.PureComponent:extend("AssetRender")
Typecheck.wrap(AssetRender, script)

function AssetRender:init()
	self.state = {
		treeViewSelection = {},
		treeViewExpansion = {},
		treeViewVisible = false,
	}

	-- InstanceTreeView needs a list of instances (where we always pass a single instance)
	-- In order to avoid passing a new table every time we render, maintain a map of
	-- (instance) -> (list containing instance) here.
	self.memoizedTreeViewInstances = {}

	self.toggleTreeViewVisible = function()
		self:setState(function(prevState)
			return {
				treeViewVisible = not prevState.treeViewVisible
			}
		end)
	end

	self.onTreeViewExpansionChange = function(expansion)
		self:setState({
			treeViewExpansion = join(self.state.treeViewExpansion, expansion)
		})
	end

	self.onTreeViewSelectionChange = function(selection)
		self:setState({
			treeViewSelection = selection
		})
	end
end

function AssetRender:getMemoizedTreeViewInstances(instance)
	local memoized = self.memoizedTreeViewInstances[instance]
	if memoized == nil then
		memoized = {instance}
		self.memoizedTreeViewInstances[instance] = memoized
	end

	return memoized
end

function AssetRender:render()
	local props = self.props
	local state = self.state

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end
	local width = props.Width

	local assetId = props.AssetData.Asset.Id

	local treeViewRootInstance = props.AssetInstance

	-- The tree view supports multiple selections, but we do not.
	local treeViewSelectedInstance = Cryo.Dictionary.keys(state.treeViewSelection)[1]
	local instance = treeViewSelectedInstance or props.AssetInstance

	local renderType = AssetRenderUtil:getRenderType(instance)
	local isPlugin = props.AssetData.Asset.TypeId == Enum.AssetType.Plugin.Value

	local treeViewEnabled = not props.DisableTreeView and treeViewRootInstance and not isPlugin
	local treeViewVisible = treeViewEnabled and state.treeViewVisible
	local renderViewSize = style.RenderView.Size
	local treeViewSize = style.TreeView.Size

	-- Tree View is displayed next to the renderView when the frame is sufficiently wide
	local treeViewHorizontal = width > renderViewSize.Y.Offset * 2

	if treeViewVisible and treeViewHorizontal then
		treeViewSize = style.TreeView.HorizontalSize
		renderViewSize = UDim2.new(renderViewSize.X - treeViewSize.X, renderViewSize.Y)
	end

	local totalHeight = treeViewVisible and not treeViewHorizontal and
		renderViewSize.Y + treeViewSize.Y or renderViewSize.Y

	local renderView

	-- Plugins are a special case where no AssetInstance prop is available
	if isPlugin then
		local THUMBNAIL_SIZE = 420

		renderView = Roact.createElement(AssetRenderImage, {
			Image = string.format(
				"rbxthumb://type=Asset&id=%d&w=%d&h=%d",
				assetId,
				THUMBNAIL_SIZE,
				THUMBNAIL_SIZE
			)
		})
	elseif renderType == nil then
		renderView = Roact.createElement(LoadingIndicator, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
		})
	elseif renderType == AssetRenderType.Model then
		renderView = Roact.createElement(AssetRenderModel, {
			Model = instance,
			OnMouseEnter = props.OnMouseEnter,
			OnMouseLeave = props.OnMouseLeave,
		})
	elseif renderType == AssetRenderType.Sound then
		renderView = Roact.createElement(AudioPlayer, {
			OnPlay = props.OnPlaySound,
			OnPause = props.OnPauseSound,
			SoundId = treeViewSelectedInstance and treeViewSelectedInstance.SoundId or string.format("rbxassetid://%d", assetId),
			Style = treeViewEnabled and style.AudioPlayerWithTreeViewButton or style.AudioPlayer,
		})
	elseif renderType == AssetRenderType.Video then
		renderView = Roact.createElement(VideoPlayer, {
			OnPlay = props.OnPlayVideo,
			OnPause = props.OnPauseVideo,
			VideoId = treeViewSelectedInstance and treeViewSelectedInstance.Video or string.format("rbxassetid://%d", assetId),
			Style = treeViewEnabled and style.VideoPlayerWithTreeViewButton or style.VideoPlayer,
		})
	elseif renderType == AssetRenderType.Image then
		renderView = Roact.createElement(AssetRenderImage, {
			Image = instance,
		})
	elseif renderType == AssetRenderType.Script or renderType == AssetRenderType.Other then
		renderView = Roact.createElement(AssetRenderThumbnail, {
			Instance = instance,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
		})
	else
		error(string.format("Unhandled AssetRenderType: %s", tostring(renderType)))
	end

	return Roact.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Margin = props.Margin,
		Padding = props.Padding,
		Size = UDim2.new(UDim.new(0, width), totalHeight),
		Background = style.Background,
		BackgroundStyle = style.BackgroundStyle,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = treeViewHorizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		RenderView = Roact.createElement(Container, {
			LayoutOrder = 1,
			Size = renderViewSize,
		}, {
			AssetRenderView = renderView,
			TreeViewButton = treeViewEnabled and Roact.createElement(Button, {
				Style = style.RenderView.TreeViewButton,
				OnClick = self.toggleTreeViewVisible,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -7, 1, -7),
				ZIndex = 2,
			}, {
				Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
			}),
		}),
		TreeView = treeViewVisible and Roact.createElement(InstanceTreeView, {
			LayoutOrder = 2,
			Size = treeViewSize,
			Instances = self:getMemoizedTreeViewInstances(treeViewRootInstance),
			Expansion = state.treeViewExpansion,
			Selection = state.treeViewSelection,
			OnExpansionChange = self.onTreeViewExpansionChange,
			OnSelectionChange = self.onTreeViewSelectionChange,
		}),
	})
end

ContextServices.mapToProps(AssetRender, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return AssetRender