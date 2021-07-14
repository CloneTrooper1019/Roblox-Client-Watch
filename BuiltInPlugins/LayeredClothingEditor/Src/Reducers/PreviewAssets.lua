local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	prebuiltAssetsInfo = {}, -- { id = {name=..., description=...}, id2 = {name=..., description=...}}
}, {
	SetPrebuiltAssetsInfo = function(state, action)
		return Cryo.Dictionary.join(state, {
			prebuiltAssetsInfo = action.prebuiltAssetsInfo,
		})
	end,
})