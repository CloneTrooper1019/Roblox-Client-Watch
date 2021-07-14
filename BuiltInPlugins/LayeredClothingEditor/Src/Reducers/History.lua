local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	past = {},
	future = {},
}, {
	SetPast = function(state, action)
		return Cryo.Dictionary.join(state, {
			past = action.past,
		})
	end,

	SetFuture = function(state, action)
		return Cryo.Dictionary.join(state, {
			future = action.future,
		})
	end,
})