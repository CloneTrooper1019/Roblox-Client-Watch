local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Signal = require(Framework.Util.Signal)
local Immutable = require(Framework.Util.Immutable)

local StatelessVideoPlayer = require(script.Parent)

return function()
	local baseProps = {
		VideoId = "rbxassetid://5608250999",
		IsPlaying = false,
		IsLoaded = true,
		TimeLength = 15,
		CurrentTime = 0,
		OnEnd = function() end,
		OnPause = function() end,
		OnPlay = function() end,
		SetIsLoaded = function() end,
		SetCurrentTime = function() end,
		SetTimeLength = function() end,
		MediaPlayerSignal = Signal.new(),
	}

	return {
		Paused = Roact.createElement(StatelessVideoPlayer, baseProps),
		PausedLoading = Roact.createElement(StatelessVideoPlayer, Immutable.JoinDictionaries(baseProps, {
			IsLoaded = false,
		})),
		Playing = Roact.createElement(StatelessVideoPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
		})),
		PlayingProgress = Roact.createElement(StatelessVideoPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
			CurrentTime = 12,
		})),
		PlayingLoading = Roact.createElement(StatelessVideoPlayer, Immutable.JoinDictionaries(baseProps, {
			IsPlaying = true,
			IsLoaded = false,
		})),
	}
end