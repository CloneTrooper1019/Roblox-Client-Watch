local ContentProvider = game:GetService("ContentProvider")

local LoadingRoot = script.Parent
local UIBloxRoot = LoadingRoot.Parent
local Roact = require(UIBloxRoot.Parent.Roact)
local ShimmerPanel = require(script.Parent.ShimmerPanel)
local withStyle = require(UIBloxRoot.Style.withStyle)
local t = require(UIBloxRoot.Parent.t)

local Images = require(UIBloxRoot.ImageSet.Images)
local ImageSetComponent = require(UIBloxRoot.ImageSet.ImageSetComponent)

local decal = Instance.new("Decal")
local inf = math.huge
local loadedImagesByUri = {}

local LoadingState = {
	InProgress = "InProgress",
	Failed = "Failed",
	Loaded = "Loaded",
}

local function shouldLoadImage(image)
	return image ~= nil and not loadedImagesByUri[image]
end

local validateProps = t.strictInterface({
	-- The anchor point of the final and loading image
	AnchorPoint = t.optional(t.Vector2),
	-- The background color of the final image. Defaults to placeholder background color.
	BackgroundColor3 = t.optional(t.Color3),
	-- The background transparency of the final image. Defaults to placeholder transparency.
	BackgroundTransparency = t.optional(t.number),
	-- The final image
	Image = t.optional(t.string),
	-- The transparency of the loading image
	ImageTransparency = t.optional(t.number),
	-- The layout order of the final and loading image
	LayoutOrder = t.optional(t.integer),
	-- The loading image which shows if useShimmerAnimationWhileLoading is false
	loadingImage = t.optional(t.string),
	-- The max size of the final and loading image
	MaxSize = t.optional(t.Vector2),
	-- The min size of the final and loading image
	MinSize = t.optional(t.Vector2),
	-- The function to call when loading is complete
	onLoaded = t.optional(t.callback),
	-- The position point of the loading image
	Position = t.optional(t.UDim2),
	-- The scale type of the final and loading image
	ScaleType = t.optional(t.enum(Enum.ScaleType)),
	-- The size point of the loading image
	Size = t.UDim2,
	-- Whether or not to show a static image or the shimmer animation while loading
	useShimmerAnimationWhileLoading = t.optional(t.boolean),
	-- Whether to show failed state when failed
	showFailedStateWhenLoadingFailed = t.optional(t.boolean),
	-- The ZIndex of the loading and final images
	ZIndex = t.optional(t.integer),
})

local LoadableImage = Roact.PureComponent:extend("LoadableImage")

LoadableImage.defaultProps = {
	BackgroundTransparency = 0,
	MaxSize = Vector2.new(inf, inf),
	MinSize = Vector2.new(0, 0),
	useShimmerAnimationWhileLoading = false,
	showFailedStateWhenLoadingFailed = false,
}

function LoadableImage:init()
	self.state = {
		loadingState = loadedImagesByUri[self.props.Image] and LoadingState.Loaded or LoadingState.InProgress,
	}
	self._isMounted = false


	self.isLoadingComplete = function(image)
		if image == Roact.None or image == nil then
			return false
		else
			return self.state.loadingState ~= LoadingState.InProgress
		end
	end
end

function LoadableImage:render()
	assert(validateProps(self.props))

	local anchorPoint = self.props.AnchorPoint
	local layoutOrder = self.props.LayoutOrder
	local size = self.props.Size
	local position = self.props.Position
	local backgroundColor3 = self.props.BackgroundColor3
	local backgroundTransparency = self.props.BackgroundTransparency
	local scaleType = self.props.ScaleType
	local zIndex = self.props.ZIndex
	local image = self.props.Image
	local imageTransparency = self.props.ImageTransparency
	local maxSize = self.props.MaxSize
	local minSize = self.props.MinSize
	local loadingImage = self.props.loadingImage
	local useShimmerAnimationWhileLoading = self.props.useShimmerAnimationWhileLoading
	local showFailedStateWhenLoadingFailed = self.props.showFailedStateWhenLoadingFailed
	local loadingComplete = self.isLoadingComplete(image)
	local loadingFailed = self.state.loadingState == LoadingState.Failed
	local hasUISizeConstraint = false

	if maxSize.X ~= inf or maxSize.Y ~= inf or minSize.X ~= 0 or minSize.Y ~= 0 then
		hasUISizeConstraint = true
	end

	local sizeConstraint = hasUISizeConstraint and Roact.createElement("UISizeConstraint", {
		MaxSize = maxSize,
		MinSize = minSize,
	})

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		if loadingFailed and showFailedStateWhenLoadingFailed then
			local failedImage = Images["icons/imageUnavailable"]
			local failedImageSize = failedImage.ImageRectSize / Images.ImagesResolutionScale

			return Roact.createElement("Frame", {
				AnchorPoint = anchorPoint,
				BorderSizePixel = 0,
				BackgroundColor3 = theme.PlaceHolder.Color,
				BackgroundTransparency = theme.PlaceHolder.Transparency,
				LayoutOrder = layoutOrder,
				Position = position,
				Size = size,
				ZIndex = zIndex,
			}, {
				EmptyIcon = Roact.createElement(ImageSetComponent.Label, {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = failedImage,
					ImageColor3 = theme.UIDefault.Color,
					ImageTransparency = theme.UIDefault.Transparency,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, failedImageSize.X, 0, failedImageSize.Y),
				}),
				UISizeConstraint = sizeConstraint,
			})
		elseif not loadingComplete and useShimmerAnimationWhileLoading then
			return Roact.createElement("Frame", {
				AnchorPoint = anchorPoint,
				BorderSizePixel = 0,
				BackgroundColor3 = theme.PlaceHolder.Color,
				BackgroundTransparency = theme.PlaceHolder.Transparency,
				LayoutOrder = layoutOrder,
				Position = position,
				Size = size,
				ZIndex = zIndex,
			}, {
				Shimmer = Roact.createElement(ShimmerPanel, {
					Size = UDim2.new(1, 0, 1, 0),
				}),
				UISizeConstraint = sizeConstraint,
			})
		else
			return Roact.createElement(ImageSetComponent.Label, {
				AnchorPoint = anchorPoint,
				BackgroundColor3 = backgroundColor3 or theme.PlaceHolder.Color,
				BackgroundTransparency = backgroundTransparency or theme.PlaceHolder.Transparency,
				BorderSizePixel = 0,
				Image = loadingComplete and image or loadingImage,
				ImageTransparency = imageTransparency,
				LayoutOrder = layoutOrder,
				Position = position,
				ScaleType = scaleType,
				Size = size,
				ZIndex = zIndex,
			}, {
				UISizeConstraint = sizeConstraint,
			})
		end
	end)
end

function LoadableImage:didUpdate(oldProps)
	if oldProps.Image ~= self.props.Image then
		self:_loadImage()
	end
end

function LoadableImage:didMount()
	self._isMounted = true

	self:_loadImage()
end

function LoadableImage:willUnmount()
	self._isMounted = false
end

function LoadableImage:_loadImage()
	local image = self.props.Image

	if shouldLoadImage(image) then
		self:setState({
			loadingState = LoadingState.InProgress
		})
	else
		if loadedImagesByUri[image] then
			self:setState({
				loadingState = LoadingState.Loaded
			})
		end
		return
	end

	-- Synchronization/Batching work should be done in engine for performance improvements
	-- related ticket: CLIPLAYEREX-1764
	spawn(function()
		local loadingFailed = false
		decal.Texture = image
		ContentProvider:PreloadAsync({decal}, function(contentId, assetFetchStatus)
			if contentId == image and assetFetchStatus == Enum.AssetFetchStatus.Failure then
				loadingFailed = true
			end
		end)

		if not loadingFailed then
			loadedImagesByUri[image] = true
		end

		if self._isMounted then
			self:setState({
				loadingState = loadingFailed and LoadingState.Failed or LoadingState.Loaded,
			})

			if self.props.onLoaded then
				self.props.onLoaded()
			end
		end
	end)
end

function LoadableImage._mockPreloadDone(image)
	loadedImagesByUri[image] = true
end

function LoadableImage.isLoaded(image)
	if image == Roact.None or image == nil then
		return false
	else
		return loadedImagesByUri[image] ~= nil
	end
end

return LoadableImage
