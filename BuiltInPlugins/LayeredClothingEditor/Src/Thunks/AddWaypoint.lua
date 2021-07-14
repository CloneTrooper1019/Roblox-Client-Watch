local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)

local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy
local Constants = require(Plugin.Src.Util.Constants)

return function()
	return function(store)
		local state = store:getState()

		local latticeData = state.latticeTool.latticeData
		local pointData = state.cageData.pointData
		local editingCage = state.selectItem.editingCage
		local past = state.history.past

		past = Cryo.List.join({
			{
				latticeData = deepCopy(latticeData),
				pointData = deepCopy(pointData),
				editingCage = editingCage,
			},
		}, past)

		past = Cryo.List.filter(past, function(value, index)
			return index <= Constants.MAX_WAYPOINTS
		end)

		store:dispatch(SetPast(past))
		store:dispatch(SetFuture({}))
	end
end