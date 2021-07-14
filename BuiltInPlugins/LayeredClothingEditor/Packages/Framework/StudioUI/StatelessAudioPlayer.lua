--[[
	Uncontrolled (stateless) audio player component.

	Required Props:
		string SoundId: The ID of the sound to play. (should be prefixed with rbxassetid://)
		number TimeLength: The length of the media (seconds).
		number CurrentTime: Current position within the media (seconds).
		boolean IsPlaying: Whether or not the media is currently playing.
		boolean IsLoaded: Whether or not the media is loaded.
		callback OnEnd: Called when the media ends.
		callback OnPause: Called when clicking the pause button.
		callback OnPlay: Called when clicking the play button.
		callback SetIsLoaded: Called when the media loads or unloads.
			SetIsLoaded(isLoaded: boolean)
		callback SetCurrentTime: May be called to set the current time (seconds).
		callback SetTimeLength: May be called to set the media length (seconds).
		Signal MediaPlayerSignal: Used to listen for imperatives from the parent (e.g. "Play" based on an external action).

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Vector2 AnchorPoint: The AnchorPoint of the component
		number LayoutOrder: The LayoutOrder of the component
		UDim2 Position: The Position of the component
		Style Style: The styling for the component.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps. TODO: Remove with FFlagStudioStopUsingPluginSoundApis
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local UI = require(Framework.UI)
local Container = UI.Container
local Image = UI.Decoration.Image

local MediaPlayerControls = require(Framework.StudioUI.MediaPlayerControls)
local MediaPlayerSignal = require(Framework.StudioUI.MediaPlayerWrapper.MediaPlayerSignal)

local FFlagStudioStopUsingPluginSoundApis = game:GetFastFlag("StudioStopUsingPluginSoundApis")

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StatelessAudioPlayer = Roact.PureComponent:extend("StatelessAudioPlayer")
Typecheck.wrap(StatelessAudioPlayer, script)

function StatelessAudioPlayer:init()
	self.soundRef = Roact.createRef()

	self.onSoundChange = function(rbx, property)
		local soundObj = self.soundRef:getValue()
		if not soundObj or not self.isMounted then
			return
		end
		local isLoaded = soundObj and soundObj.IsLoaded
		if property == "TimeLength" then
			self.props.SetTimeLength(soundObj.TimeLength)
			self.props.SetIsLoaded(isLoaded)
		elseif isLoaded ~= self.props.IsLoaded then
			self.props.SetIsLoaded(isLoaded)
		end
	end

	self.handleMediaPlayerSignal = function(updateType)
		local soundObj = self.soundRef:getValue()
		if not soundObj or not self.isMounted then
			return
		end

		if updateType == MediaPlayerSignal.PLAY then
			soundObj.SoundId = self.props.SoundId
			if FFlagStudioStopUsingPluginSoundApis then
				soundObj.Playing = true
			else
				self.props.Plugin:get():PlaySound(soundObj, self.props.CurrentTime / self.props.TimeLength)
			end
		elseif updateType == MediaPlayerSignal.PAUSE then
			if FFlagStudioStopUsingPluginSoundApis then
				soundObj.Playing = false
			else
				self.props.Plugin:get():PauseSound(soundObj)
			end
		elseif updateType == MediaPlayerSignal.SET_TIME then
			if self.props.IsPlaying then
				if FFlagStudioStopUsingPluginSoundApis then
					soundObj.TimePosition = self.props.CurrentTime
				else
					self.props.Plugin:get():PlaySound(soundObj, self.props.CurrentTime / self.props.TimeLength)
				end
			end
		end
	end
end

function StatelessAudioPlayer:didMount()
	self.isMounted = true
	self.mediaPlayerSignalConnection = self.props.MediaPlayerSignal:Connect(self.handleMediaPlayerSignal)
end

function StatelessAudioPlayer:willUnmount()
	self.isMounted = false
	if self.mediaPlayerSignalConnection then
		self.mediaPlayerSignalConnection:Disconnect()
		self.mediaPlayerSignalConnection = nil
	end
end

function StatelessAudioPlayer:render()
	local props = self.props

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local layoutOrder = props.LayoutOrder
	local position = props.Position
	local size = props.Size

	local controlsSize = MediaPlayerControls.calculateSize(style.MediaPlayerControls)

	return Roact.createElement(Container, {
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

		PlaceholderImageFrame = Roact.createElement(Container, {
			LayoutOrder = 1,
			Size = UDim2.new(UDim.new(1, 0), UDim.new(1, 0) - controlsSize.Y),
		}, {
			PlaceholderImage = Roact.createElement(Image, {
				Style = style.PlaceholderImage,
			})
		}),

		MediaPlayerControls = Roact.createElement(MediaPlayerControls, {
			LayoutOrder = 2,
			Style = style.MediaPlayerControls,
			IsPlaying = props.IsPlaying,
			IsLoaded = props.IsLoaded,
			OnPause = props.OnPause,
			OnPlay = props.OnPlay,
			TimeLength = props.TimeLength,
			CurrentTime = props.CurrentTime,
			OnScrub = props.SetCurrentTime,
		}),

		SoundObj = Roact.createElement("Sound", {
			Looped = false,
			SoundId = props.SoundId,
			[Roact.Ref] = self.soundRef,
			[Roact.Event.Changed] = self.onSoundChange,
			[Roact.Event.Ended] = props.OnEnd,
		})
	})
end

ContextServices.mapToProps(StatelessAudioPlayer, {
	Plugin = (not FFlagStudioStopUsingPluginSoundApis) and ContextServices.Plugin or nil,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return StatelessAudioPlayer
