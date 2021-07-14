local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
		clickedPoints = {},
		selectedPoints = {},
		falloff = 0.5,
	}, {
	SetSelectedPoints = function(state, action)
		return Cryo.Dictionary.join(state, {
			selectedPoints = action.selectedPoints,
		})
	end,
	SetClickedPoints = function(state, action)
		return Cryo.Dictionary.join(state, {
			clickedPoints = action.clickedPoints,
		})
	end,
	SetFalloff = function(state, action)
		return Cryo.Dictionary.join(state, {
			falloff = action.falloff,
		})
	end,
})