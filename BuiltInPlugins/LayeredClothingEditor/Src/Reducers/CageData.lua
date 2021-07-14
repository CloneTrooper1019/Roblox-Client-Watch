local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	pointData = {},
	}, {
	SetPointData = function(state, action)
		return Cryo.Dictionary.join(state, {
			pointData = action.pointData,
		})
	end,

	SetPolyData = function(state, action)
		return Cryo.Dictionary.join(state, {
			polyData = action.polyData,
		})
	end,

	SetBoundsData = function(state, action)
		return Cryo.Dictionary.join(state, {
			boundsData = action.boundsData,
		})
	end,

	SetSeamData = function(state, action)
		return Cryo.Dictionary.join(state, {
			seamData = action.seamData,
		})
	end,

	SetOriginalPointData = function(state, action)
		return Cryo.Dictionary.join(state, {
			originalPointData = action.originalPointData,
		})
	end,
})