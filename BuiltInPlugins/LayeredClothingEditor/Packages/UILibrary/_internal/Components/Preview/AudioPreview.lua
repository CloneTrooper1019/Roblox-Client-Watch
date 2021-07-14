--[[
	This component will be used in the asset preview for audio asset.
	It will provide a still image for sound asset and a progress bar.
	The progress bar will keep moving if the sound is playing.

	Necessary properties:
		number SoundId, used for play and pause the sound
		bool ShowTreeView, used to adjust time label component for audio control based on if we are
			showing tree view button or not.

	Optional properties:
		UDim2 position, default to UDim2(0, 0, 0, 0)
		UDim2 size, default to UDim2(1, 0, 1, 0)
		number layoutOrder, used by the layouter to change the position of the component
		callBack ReportPlay, analytics events.
		callback ReportPause,

	Props automatically received from wrapMedia():
		number _CurrentTime: The time in seconds that the media's TimePosition should currently be.
		boolean _IsPlaying: Whether or not the Sound or VideoFrame should be currently playing.
		callback _MediaPlayingUpdateSignal: Called when the media's Changed event is fired. Sets the isPlaying state.
		callback _OnMediaEnded: Called when the media's Ended event is fired. Resets the currentTime & stops playing.
		callback _Pause: Called when clicking the pause button.
		callback _Play: Called when clicking the play button.
		callBack _SetCurrentTime: Called if the currentTime has been changed, such as when moving a progressbar slider.
]]
local FFlagHideOneChildTreeviewButton = game:GetFastFlag("HideOneChildTreeviewButton")
local FFlagStudioStopUsingPluginSoundApis = game:GetFastFlag("StudioStopUsingPluginSoundApis")

local wrapMedia = require(script.Parent.wrapMedia)

local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local PluginContext = require(Library.Plugin)
local getPlugin = PluginContext.getPlugin

local PROGRESS_BAR_HEIGHT = 6
local AUDIO_CONTROL_HEIGHT = 35
local AUDIO_CONTROL_WIDTH_OFFSET_NO_TREE = 70

if FFlagHideOneChildTreeviewButton then
	AUDIO_CONTROL_WIDTH_OFFSET_NO_TREE = 10
end

local MediaControl = require(Library.Components.Preview.MediaControl)

local AudioPreview = Roact.PureComponent:extend("AudioPreview")

AudioPreview.defaultProps = {
	size = UDim2.new(1, 0, 1, 0),
}

function AudioPreview:init(props)
	-- TODO: Remove with FFlagStudioStopUsingPluginSoundApis
	local plugin = (not FFlagStudioStopUsingPluginSoundApis) and getPlugin(self) or nil
	self.soundRef = Roact.createRef()

	self.state = {
		timeLength = 0,
		isLoaded = false,
	}

	self.dispatchMediaPlayingUpdate = function(updateType)
		local soundObj = self.soundRef.current
		if not soundObj or not self.isMounted then
			return
		end
		if updateType == "PLAY" then
			soundObj.SoundId = self.props.SoundId
			if FFlagStudioStopUsingPluginSoundApis then
				soundObj.Playing = true
			else
				plugin:ResumeSound(soundObj)
			end
			if self.props.reportPlay then
				self.props.ReportPlay()
			end
		elseif updateType == "PAUSE" then
			if FFlagStudioStopUsingPluginSoundApis then
				soundObj.Playing = false
			else
				plugin:PauseSound(soundObj)
			end
			if self.props.ReportPause then
				self.props.ReportPause()
			end
		end
	end

	self.onSoundChange = function(rbx, property)
		local soundObj = self.soundRef.current
		if not self.isMounted then
			return
		end
		local isLoaded = soundObj and soundObj.IsLoaded
		if property == "TimeLength" then
			self:setState({
				isLoaded = isLoaded,
				timeLength = soundObj.TimeLength,
			})
			self.props._SetTimeLength(soundObj.TimeLength)

		elseif isLoaded ~= self.state.isLoaded then
			self:setState({
				isLoaded = isLoaded,
			})
		end
	end

	self.getAudioLength = function()
		local soundObj = self.soundRef.current
		if soundObj then
			return math.max(soundObj.TimeLength, 1)
		end
	end
end

function AudioPreview:didMount()
	self.isMounted = true
	self.mediaPlayingUpdateConnection = self.props._MediaPlayingUpdateSignal:connect(self.dispatchMediaPlayingUpdate)
end

function AudioPreview:willUnmount()
	self.isMounted = false
	if self.mediaPlayingUpdateConnection then
		self.mediaPlayingUpdateConnection:disconnect()
		self.mediaPlayingUpdateConnection = nil
	end
end

function AudioPreview:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state
		local position = props.position
		local size = props.size
		local audioPreviewTheme = theme.assetPreview.audioPreview

		local layoutOrder = props.layoutOrder
		local soundId = props.SoundId

		local currentTime = props._CurrentTime
		local pause = props._Pause
		local play = props._Play
		local onMediaEnded = props._OnMediaEnded

		local progress
		if state.timeLength ~= nil and state.timeLength ~= 0 then
			progress = currentTime / state.timeLength
		else
			progress = 0
		end

		local showTreeView = props.ShowTreeView
		local timeLength = self.getAudioLength() or 0
		local isLoaded = state.isLoaded
		local isPlaying = props._IsPlaying

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BackgroundColor3 = audioPreviewTheme.backgroundColor,
			LayoutOrder = layoutOrder,
			Position = position,
			Size = size,
		},{
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			AudioPlayerFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, -PROGRESS_BAR_HEIGHT- AUDIO_CONTROL_HEIGHT),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				AudioPlayerImage = Roact.createElement("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					Image = audioPreviewTheme.audioPlay_BG,
					ScaleType = Enum.ScaleType.Fit,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ImageColor3 = audioPreviewTheme.audioPlay_BG_Color,
				})
			}),

			ProgressBarFrame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, PROGRESS_BAR_HEIGHT),

				BackgroundColor3 = audioPreviewTheme.progressBar_BG_Color,
				BorderSizePixel = 0,
				BackgroundTransparency = 0,

				LayoutOrder = 2,
			}, {
				ProgressBar = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = audioPreviewTheme.progressBar,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(progress, 0, 0, PROGRESS_BAR_HEIGHT),
				})
			}),

			MediaControl = Roact.createElement(MediaControl, {
				LayoutOrder = 3,
				IsPlaying = isPlaying,
				IsLoaded = isLoaded,
				OnPause = pause,
				OnPlay = play,
				ShowTreeView = showTreeView,
				TimeLength = timeLength,
				TimePassed = currentTime,
			}),

			SoundObj = Roact.createElement("Sound", {
				Looped = false,
				SoundId = soundId,
				[Roact.Ref] = self.soundRef,
				[Roact.Event.Changed] = self.onSoundChange,
				[Roact.Event.Ended] = onMediaEnded,
			})
		})
	end)
end

return wrapMedia(AudioPreview)
