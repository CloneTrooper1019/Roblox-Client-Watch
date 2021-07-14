local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Signal = require(Framework.Util.Signal)
local Immutable = require(Framework.Util.Immutable)

local StatelessAudioPlayer = require(script.Parent)

return function()
	local baseProps = {
		SoundId = "rbxassetid://1837461008",
		IsPlaying = false,
		IsLoaded = true,
		TimeLength = 120,
		CurrentTime = 0,
		OnEnd = function() end,
		OnPause = function() end,
		OnPlay = function() end,
		SetIsLoaded = function() end,
		SetCurrentTime = function() end,
		SetTimeLength = function() end,
		MediaPlayerSignal = Signal.new()
	}

	return {
		Paused = Roact.createElement(StatelessAudioPlayer, baseProps),
		PausedLoading = Roact.createElement(StatelessAudioPlayer, Immutable.JoinDictionaries(baseProps, {
			IsLoaded = false,
		})),
		Playing = Roact.createElement(StatelessAudioPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
		})),
		PlayingProgress = Roact.createElement(StatelessAudioPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
			CurrentTime = 59,
		})),
		PlayingLoading = Roact.createElement(StatelessAudioPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
			IsLoaded = false,
		})),
	}
end