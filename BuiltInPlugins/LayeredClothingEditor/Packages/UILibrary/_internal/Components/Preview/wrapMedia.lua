--[[
	Wraps a component with logic required for a media's time progressbar, play/pause button, and time countdown.

	Returns:
		number _CurrentTime: The time in seconds that the media's TimePosition should currently be.
		boolean _IsPlaying: Whether or not the Sound or VideoFrame should be currently playing.
		callback _MediaPlayingUpdateSignal: Should be called when the media's Changed event is fired. Sets the isPlaying state.
		callback _OnMediaEnded: Should be called when the media's Ended event is fired. Resets the currentTime & stops playing.
		callback _Pause: Should be called when clicking the pause button.
		callback _Play: Should be called when clicking the play button.
		callBack _SetCurrentTime: Should be called if the currentTime has been changed, such as when moving a progressbar slider.
		callBack _SetTimeLength: Should be called if the timeLnegth has been changed, such as when a new audio or video is loaded.
]]
local RunService = game:GetService("RunService")

local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Signal = require(Library.Utils.Signal)
local Immutable = require(Library.Utils.Immutable)

local function wrapMedia(wrappedComponent)
	local MediaWrapper = Roact.PureComponent:extend(("MediaWrapper(%s)"):format(tostring(wrappedComponent)))

	function MediaWrapper:init()
		self.state = {
			currentTime = 0,
			isPlaying = false,
			timeLength = 0,
		}

		self.mediaPlayingUpdateSignal = Signal.new()

		self.play = function()
			self.mediaPlayingUpdateSignal:fire("PLAY")
			self:setState({
				isPlaying = true,
			})
		end

		self.pause = function()
			self.mediaPlayingUpdateSignal:fire("PAUSE")
			self:setState({
				isPlaying = false,
			})
		end

		self.onMediaEnded = function()
			self:setState({
				currentTime = 0,
				isPlaying = false,
			})
		end

		self.setCurrentTime = function(currentTime)
			self:setState({
				currentTime = currentTime,
			})
		end

		self.setTimeLength = function(timeLength)
			self:setState({
				timeLength = timeLength,
			})
		end

		self.onRenderStepped = function(deltaTime)
			if not self.isMounted or not self.state.isPlaying then
				return
			end

			local newTime = self.state.currentTime + deltaTime

			if newTime >= self.state.timeLength then
				self.onMediaEnded()
				self.mediaPlayingUpdateSignal:fire("END")
			else
				self:setState({
					currentTime = newTime,
				})
			end
		end
	end

	function MediaWrapper:didMount()
		self.isMounted = true
		self.runServiceConnection = RunService.RenderStepped:Connect(self.onRenderStepped)
	end

	function MediaWrapper:willUnmount()
		self.isMounted = false
		if self.runServiceConnection then
			self.runServiceConnection:Disconnect()
			self.runServiceConnection = nil
		end
	end

	function MediaWrapper:render()
		local props = Immutable.JoinDictionaries(self.props, {
			_CurrentTime = self.state.currentTime,
			_IsPlaying = self.state.isPlaying,
			_MediaPlayingUpdateSignal = self.mediaPlayingUpdateSignal,
			_OnMediaEnded = self.onMediaEnded,
			_Play = self.play,
			_Pause = self.pause,
			_SetCurrentTime = self.setCurrentTime,
			_SetTimeLength = self.setTimeLength,
		})

		return Roact.createElement(wrappedComponent, props)
	end

	return MediaWrapper
end

return wrapMedia