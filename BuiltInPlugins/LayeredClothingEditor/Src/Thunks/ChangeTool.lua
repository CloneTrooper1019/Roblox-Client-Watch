local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetToolMode = require(Plugin.Src.Actions.SetToolMode)
local SetSelectedLattice = require(Plugin.Src.Actions.SetSelectedLattice)

local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)
local SelectControlPoint = require(Plugin.Src.Thunks.SelectControlPoint)

return function(mode)
	return function(store)
		store:dispatch(SelectRbfPoint({}))
		store:dispatch(SelectControlPoint({}))
		store:dispatch(SetSelectedLattice(Cryo.None))
		store:dispatch(SetToolMode(mode))
	end
end