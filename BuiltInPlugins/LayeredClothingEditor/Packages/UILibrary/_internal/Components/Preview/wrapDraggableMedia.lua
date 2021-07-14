--[[
	Wraps a component with logic required for a media's time interactable progressbar, play/pause button,
	and time countdown. The wrapped component passes all props that wrapMedia in addition to interactable slider logic.

	Props automatically received from wrapMedia():
		boolean IsPlaying: Whether or not the Sound or VideoFrame is currently playing.
		callback Pause: Called when clicking the pause button.
		callback Play: Called when clicking the play button.
		callBack SetCurrentTime: Called if the currentTime has been changed, such as when moving a progressbar slider.

	Returns:
		callback _OnSliderInputChanged: Called when the progressbar slider input is changed.
		callback _OnSliderInputEnded: Called when the progressbar slider input ends.

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
local wrapMedia = require(script.Parent.wrapMedia)
local Immutable = require(Library.Utils.Immutable)

local function wrapDraggableMedia(wrappedComponent)
	local componentName = wrappedComponent and wrappedComponent.component and tostring(wrappedComponent.component) or ""
	local DraggableMediaWrapper = Roact.PureComponent:extend(("DraggableMediaWrapper(%s)"):format(componentName))

	function DraggableMediaWrapper:init()
		self.isPlayingBeforeDrag = nil

		self.onSliderInputChanged = function(newValue)
			local isPlaying = self.props._IsPlaying
			if self.isPlayingBeforeDrag == nil then
				self.isPlayingBeforeDrag = isPlaying
			end

			if isPlaying then
				self.props._Pause()
			end

			self.props._SetCurrentTime(newValue)
		end

		self.onSliderInputEnded = function()
			if self.isPlayingBeforeDrag then
				self.props._Play()
			end
			self.isPlayingBeforeDrag = nil
		end
	end

	function DraggableMediaWrapper:render()
		local props = Immutable.JoinDictionaries(self.props, {
			_OnSliderInputChanged = self.onSliderInputChanged,
			_OnSliderInputEnded = self.onSliderInputEnded,
		})
		return Roact.createElement(wrappedComponent, props)
	end

	return wrapMedia(DraggableMediaWrapper)
end

return wrapDraggableMedia