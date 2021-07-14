local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
		latticeData = {},
		subdivisions = {},
		latticeBoundsData = {},
		selectedLattice = nil,
	}, {
	SetLatticeData = function(state, action)
		return Cryo.Dictionary.join(state, {
			latticeData = action.latticeData,
		})
	end,
	SetSubdivisions = function(state, action)
		return Cryo.Dictionary.join(state, {
			subdivisions = action.subdivisions,
		})
	end,
	SetLatticeBoundsData = function(state, action)
		return Cryo.Dictionary.join(state, {
			latticeBoundsData = action.latticeBoundsData,
		})
	end,
	SetSelectedLattice = function(state, action)
		return Cryo.Dictionary.join(state, {
			selectedLattice = action.selectedLattice,
		})
	end,
})