--[[
	Gathers point data for each deformer and approximates the following data for a bounding box
	based off of the points:
		- Width, Height, Depth
		- Position of center of bounding box
		- Position of each corner of the bounding box
		- Axis of the largest extent
]]

local Plugin = script.Parent.Parent.Parent

local SetBoundsData = require(Plugin.Src.Actions.SetBoundsData)

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy

return function(editingCage)
	return function(store)
		local state = store:getState()

		local pointData = state.cageData.pointData
		if not pointData then
			return
		end

		local boundsData = state.cageData.boundsData
		if not boundsData then
			boundsData = {}
		else
			boundsData = deepCopy(boundsData)
		end

		boundsData[editingCage] = {}

		for deformer, pointsPerDeformer in pairs(pointData[editingCage]) do
			boundsData[editingCage][deformer] = ModelUtil:getBounds(pointsPerDeformer)
		end
		store:dispatch(SetBoundsData(boundsData))
	end
end