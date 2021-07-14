local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Cryo = require(Framework.Util.Cryo)

local MediaPlayerControls = require(script.Parent)

return function()
	local baseProps = {
		IsPlaying = false,
		IsLoaded = true,
		OnPause = function() end,
		OnPlay = function() end,
		OnScrub = function() end,
		TimeLength = 90,
		CurrentTime = 0
	}

	return {
		Paused = Roact.createElement(MediaPlayerControls, baseProps),
		Playing = Roact.createElement(MediaPlayerControls, Cryo.Dictionary.join(baseProps, {
			IsPlaying = true
		})),
		Loading = Roact.createElement(MediaPlayerControls, Cryo.Dictionary.join(baseProps, {
			IsLoaded = false
		})),
		WithProgress = Roact.createElement(MediaPlayerControls, Cryo.Dictionary.join(baseProps, {
			IsPlaying = true,
			CurrentTime = 50
		})),
		ScrubbingDisabled = Roact.createElement(MediaPlayerControls, Cryo.Dictionary.join(baseProps, {
			IsPlaying = true,
			CurrentTime = 50,
			OnScrub = Cryo.None,
		})),
	}
end