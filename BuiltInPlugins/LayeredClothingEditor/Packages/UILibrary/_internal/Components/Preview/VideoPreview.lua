--[[
	Provides logic for a VideoFrame and it's play/pause button, progress bar, and a time label.

	Required Props:
		string VideoId: the Content string for VideoFrames. Should be formatted as a Content string "rbxassetid://123456".
		boolean ShowTreeView: whether or not to show the TreeView button. It is used to
				adjust the position of the time label and progress bar.

	Optional Props:
		UDim2 LayoutOrder: The LayoutOrder of the component
		UDim2 Position: The Position of the component
		UDim2 Size: The Size of the component
		callback OnPlay: Optional analytics call when clicking the play button
		callback OnPause: Optional analytics call when clicking the pause button

	Props automatically received from wrapDraggableMedia():
		callback OnSliderInputChanged: Called when the progressbar slider input is changed.
		callback OnSliderInputEnded: Called when the progressbar slider input ends.

	Props automatically received from wrapMedia():
		number _CurrentTime: The time in seconds that the media's TimePosition should currently be.
		boolean _IsPlaying: Whether or not the Sound or VideoFrame should be currently playing.
		callback _MediaPlayingUpdateSignal: Called when the media's Changed event is fired. Sets the isPlaying state.
		callback _OnMediaEnded: Called when the media's Ended event is fired. Resets the currentTime & stops playing.
		callback _Pause: Called when clicking the pause button.
		callback _Play: Called when clicking the play button.
		callBack _SetCurrentTime: Called if the currentTime has been changed, such as when moving a progressbar slider.
]]
local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local wrapDraggableMedia = require(script.Parent.wrapDraggableMedia)

local MediaControl = require(Library.Components.Preview.MediaControl)
local MediaProgressBar = require(Library.Components.Preview.MediaProgressBar)

local PROGRESS_BAR_TOTAL_HEIGHT = 30
local AUDIO_CONTROL_HEIGHT = 35
local ICON_SIZE = 30

local VideoPreview = Roact.PureComponent:extend("VideoPreview")

VideoPreview.defaultProps = {
	Size = UDim2.new(1, 0, 1, 0),
}

function VideoPreview:init()
	self.layoutRef = Roact.createRef()
	self.videoRef = Roact.createRef()
	self.videoContainerRef = Roact.createRef()

	self.state = {
		timeLength = 0,
		isLoaded = false,
		showOverlayPlayIcon = true,
		resolution = Vector2.new(4, 3),
	}

	self.dispatchMediaPlayingUpdate = function(updateType)
		local videoObj = self.videoRef.current
		if videoObj then
			if updateType == "PLAY" then
				videoObj:Play()
				if self.props._OnPlay then
					self.props._OnPlay()
				end
			elseif updateType == "PAUSE" then
				videoObj:Pause()
				if self.props._OnPause then
					self.props._OnPause()
				end
			elseif updateType == "END" then
				videoObj.Playing = false
				videoObj.TimePosition = 0
			end
		end
	end

	self.onVideoPropertyChanged = function(rbx, property)
		local videoObj = self.videoRef.current
		if not videoObj or not self.isMounted then
			return
		end
		if property == "TimeLength" then
			self:setState({
				isLoaded = videoObj.IsLoaded,
				timeLength = videoObj.TimeLength,
			})
			self.props._SetTimeLength(videoObj.TimeLength)
		elseif videoObj.IsLoaded ~= self.state.isLoaded then
			self:setState({
				isLoaded = videoObj.IsLoaded,
			})
		elseif property == "Resolution" then
			self:setState({
				resolution = videoObj.Resolution,
			})
			self.onResize()
		end
	end

	self.onResize = function()
		local currentLayout = self.layoutRef.current
		local videoFrame = self.videoRef.current
		local videoContainer = self.videoContainerRef.current
		if not videoFrame or not currentLayout or not videoContainer then
			return
		end

		local resolution = self.state.resolution
		local height = videoContainer.AbsoluteSize.Y
		local width = height * resolution.X / resolution.Y
		if (currentLayout.AbsoluteContentSize.X < width) then
			width = currentLayout.AbsoluteContentSize.X
			height = width * resolution.Y / resolution.X
		end
		videoFrame.Size = UDim2.new(UDim.new(0, width), UDim.new(0, height))
	end

	self.onSliderInputChanged = function(newValue)
		local videoFrame = self.videoRef.current
		videoFrame.TimePosition = newValue or 0
		videoFrame.Playing = false
		self:setState({
			showOverlayPlayIcon = false,
		})

		self.props._OnSliderInputChanged(newValue)
	end

	self.onSliderInputEnded = function()
		local videoFrameObj = self.videoRef.current
		videoFrameObj.Playing = self.props._IsPlaying
		self:setState({
			showOverlayPlayIcon = true,
		})

		self.props._OnSliderInputEnded()
	end

	self.togglePlay = function()
		if self.props._IsPlaying then
			self.props._Pause()
		else
			self.props._Play()
		end
	end
end

function VideoPreview:didMount()
	self.isMounted = true
	self.onResize()
	self.mediaPlayingUpdateConnection = self.props._MediaPlayingUpdateSignal:connect(self.dispatchMediaPlayingUpdate)
end

function VideoPreview:willUnmount()
	self.isMounted = false
	if self.mediaPlayingUpdateConnection then
		self.mediaPlayingUpdateConnection:disconnect()
		self.mediaPlayingUpdateConnection = nil
	end
end

function VideoPreview:render()
	return withTheme(function(theme)
		local VideoPreviewTheme = theme.assetPreview.videoPreview

		local props = self.props
		local state = self.state

		local isLoaded = state.isLoaded
		local timeLength = state.timeLength
		local showOverlayPlayIcon = state.showOverlayPlayIcon

		local layoutOrder = props.LayoutOrder
		local position = props.Position
		local size = props.Size
		local showTreeView = props.ShowTreeView
		local videoId = props.VideoId

		-- Props passed from wrapDraggableMedia() and wrapMedia()
		local currentTime = props._CurrentTime
		local isPlaying = props._IsPlaying
		local onMediaEnded = props._OnMediaEnded
		local pause = props._Pause
		local play = props._Play

		return Roact.createElement("Frame", {
			BackgroundColor3 = VideoPreviewTheme.backgroundColor,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
			Position = position,
			Size = size,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 10),

				[Roact.Change.AbsoluteContentSize] = self.onResize,
				[Roact.Ref] = self.layoutRef,
			}),

			VideoFrameButton = Roact.createElement("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BackgroundColor3 = VideoPreviewTheme.videoBackgroundColor,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 1, -PROGRESS_BAR_TOTAL_HEIGHT - AUDIO_CONTROL_HEIGHT),
				Text = "",

				[Roact.Ref] = self.videoContainerRef,
				[Roact.Event.Activated] = self.togglePlay,
			}, {
				VideoFrameObj = Roact.createElement("VideoFrame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Looped = false,
					Position = UDim2.new(0.5, 0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					Video = videoId,

					[Roact.Ref] = self.videoRef,
					[Roact.Event.Changed] = self.onVideoPropertyChanged,
					[Roact.Event.Ended] = onMediaEnded,
				}, {
					PauseOverlay = (not isPlaying) and Roact.createElement("Frame", {
						BackgroundColor3 = VideoPreviewTheme.pauseOverlayColor,
						BackgroundTransparency = VideoPreviewTheme.pauseOverlayTransparency,
						Size = UDim2.new(1, 0, 1, 0),
					}, {
						PlayVideoIcon = showOverlayPlayIcon and Roact.createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Image = VideoPreviewTheme.playButton,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
						}),
					}),
				}),
			}),

			ProgressBar = Roact.createElement(MediaProgressBar, {
				CurrentValue = currentTime,
				LayoutOrder = 2,
				Min = 0,
				Max = timeLength,
				OnValuesChanged = self.onSliderInputChanged,
				OnInputEnded = self.onSliderInputEnded,
			}),

			VideoControl = Roact.createElement(MediaControl, {
				LayoutOrder = 3,
				ShowTreeView = showTreeView,
				IsPlaying = isPlaying,
				IsLoaded = isLoaded,
				OnPause = pause,
				OnPlay = play,
				TimeLength = timeLength,
				TimePassed = currentTime,
			}),
		})
	end)
end

return wrapDraggableMedia(VideoPreview)