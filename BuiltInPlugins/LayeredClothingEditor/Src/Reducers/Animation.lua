local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	Playhead = 0,
	SliderPlayhead = -1,
	IsPlaying = false,
	TrackLengh = 0,
},{
	SetPlayhead = function(state, action)
		return Cryo.Dictionary.join(state, {
			Playhead = action.playhead,
		})
	end,
	SetSliderPlayhead = function(state, action)
		return Cryo.Dictionary.join(state, {
			SliderPlayhead = action.sliderPlayhead,
		})
	end,
	SetIsPlaying = function(state, action)
		return Cryo.Dictionary.join(state, {
			IsPlaying = action.isPlaying,
		})
	end,
	SetTrackLength = function(state, action)
		return Cryo.Dictionary.join(state, {
			TrackLength = action.trackLength,
		})
	end,
})