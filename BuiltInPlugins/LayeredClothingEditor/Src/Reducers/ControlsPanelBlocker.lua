local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	isActive = false,
	message = "",
	}, {
		SetControlsPanelBlockerActivity = function(state, action)
			return Cryo.Dictionary.join(state, {
				isActive = action.isActive,
			})
		end,
		SetControlsPanelBlockerMessage = function(state, action)
			return Cryo.Dictionary.join(state, {
				message = action.message,
			})
		end,
})