--[[
	State container and generic logic for creating a controlled media (Audio/Video) player.
]]
local RunService = game:GetService("RunService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Util = require(Framework.Util)
local Signal = Util.Signal
local Immutable = Util.Immutable

local MediaPlayerSignal = require(script.MediaPlayerSignal)

local function MediaPlayerWrapper(wrappedComponent)
	local MediaPlayerWrapper = Roact.PureComponent:extend(("MediaPlayerWrapper(%s)"):format(tostring(wrappedComponent)))

	function MediaPlayerWrapper:init()
		self.state = {
			currentTime = 0,
			isPlaying = false,
			isLoaded = false,
			timeLength = 0,
		}

		self.mediaPlayerSignal = Signal.new()

		self.play = function()
			self.mediaPlayerSignal:Fire(MediaPlayerSignal.PLAY)
			self:setState({
				isPlaying = true,
			})

			if self.props.OnPlay then
				self.props.OnPlay()
			end
		end

		self.pause = function()
			self.mediaPlayerSignal:Fire(MediaPlayerSignal.PAUSE)
			self:setState({
				isPlaying = false,
			})

			if self.props.OnPause then
				self.props.OnPause()
			end
		end

		self.onEnd = function()
			self:setState({
				currentTime = 0,
				isPlaying = false,
			})
			self.mediaPlayerSignal:Fire(MediaPlayerSignal.SET_TIME)
		end

		self.setIsLoaded = function(isLoaded)
			self:setState({
				isLoaded = isLoaded
			})
		end

		self.setCurrentTime = function(currentTime)
			self:setState({
				currentTime = currentTime,
			})
			self.mediaPlayerSignal:Fire(MediaPlayerSignal.SET_TIME)
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

			if newTime < self.state.timeLength then
				self:setState({
					currentTime = newTime,
				})
			end
		end
	end

	function MediaPlayerWrapper:didMount()
		self.isMounted = true
		self.runServiceConnection = RunService.RenderStepped:Connect(self.onRenderStepped)
	end

	function MediaPlayerWrapper:willUnmount()
		self.isMounted = false
		if self.runServiceConnection then
			self.runServiceConnection:Disconnect()
			self.runServiceConnection = nil
		end
	end

	function MediaPlayerWrapper:render()
		local state = self.state
		local props = Immutable.JoinDictionaries(self.props, {
			CurrentTime = state.currentTime,
			IsLoaded = state.isLoaded,
			IsPlaying = state.isPlaying,
			MediaPlayerSignal = self.mediaPlayerSignal,
			SetIsLoaded = self.setIsLoaded,
			OnEnd = self.onEnd,
			OnPlay = self.play,
			OnPause = self.pause,
			SetCurrentTime = self.setCurrentTime,
			SetTimeLength = self.setTimeLength,
			TimeLength = state.timeLength,
		})

		return Roact.createElement(wrappedComponent, props)
	end

	return MediaPlayerWrapper
end

return MediaPlayerWrapper