local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)
local SetPointData = require(Plugin.Src.Actions.SetPointData)
local SetLatticeData = require(Plugin.Src.Actions.SetLatticeData)

local SelectEditingCage = require(Plugin.Src.Thunks.SelectEditingCage)

local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy
local Constants = require(Plugin.Src.Util.Constants)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

return function()
	return function(store)
		local state = store:getState()

		local latticeData = state.latticeTool.latticeData
		local pointData = state.cageData.pointData
		local editingCage = state.selectItem.editingCage
		local past = state.history.past
		local future = state.history.future

		if #past > 0 then
			future = Cryo.List.join({
				{
					latticeData = deepCopy(latticeData),
					pointData = deepCopy(pointData),
					editingCage = editingCage,
				},
			}, future)
			future = Cryo.List.filter(future, function(value, index)
				return index <= Constants.MAX_WAYPOINTS
			end)

			store:dispatch(SetFuture(future))

			local newState = past[1]
			store:dispatch(SetLatticeData(newState.latticeData))
			store:dispatch(SetPointData(newState.pointData))
			store:dispatch(SelectEditingCage(newState.editingCage))

			store:dispatch(SetPast(Cryo.List.removeIndex(past, 1)))

			ModelUtil:updateWraps(newState.pointData, editingCage)
		end
	end
end