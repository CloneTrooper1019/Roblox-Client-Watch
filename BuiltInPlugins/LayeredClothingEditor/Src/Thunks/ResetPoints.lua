local Plugin = script.Parent.Parent.Parent

local SetPointData = require(Plugin.Src.Actions.SetPointData)

local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)
local SelectControlPoint = require(Plugin.Src.Thunks.SelectControlPoint)
local MakeLattices = require(Plugin.Src.Thunks.MakeLattices)

local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local deepCopy = Util.deepCopy

return function()
	return function(store)
		local state = store:getState()

		local editingCage = state.selectItem.editingCage
		local originalPointData = state.cageData.originalPointData

		if not originalPointData or not editingCage then
			return
		end

		store:dispatch(SetPointData(deepCopy(originalPointData)))
		store:dispatch(SelectRbfPoint({}))
		store:dispatch(SelectControlPoint({}))
		store:dispatch(MakeLattices())

		ModelUtil:updateWraps(originalPointData, editingCage)
	end
end