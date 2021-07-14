local Plugin = script.Parent.Parent.Parent

local MakeLattice = require(Plugin.Src.Thunks.MakeLattice)
local SetSubdivisions = require(Plugin.Src.Actions.SetSubdivisions)
local SetSelectedControlPoints = require(Plugin.Src.Actions.SetSelectedControlPoints)

local Framework = require(Plugin.Packages.Framework)
local deepJoin = Framework.Util.deepJoin

return function(subdivisionVector, deformer, editingCage, localAlignment)
	return function(store)
		local state = store:getState()

		if not editingCage then
			editingCage = state.selectItem.editingCage
		end

		if not editingCage then
			return
		end

		local subdivisions = state.latticeTool.subdivisions
		if deformer and subdivisionVector then
			subdivisions = deepJoin(subdivisions, {
				[editingCage] = {
					[deformer] = subdivisionVector,
				}
			})
			store:dispatch(SetSubdivisions(subdivisions))
			store:dispatch(MakeLattice(deformer, editingCage, localAlignment))
			store:dispatch(SetSelectedControlPoints({}))
		end
	end
end