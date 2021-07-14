local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local ToolUtil = require(Plugin.Src.Util.ToolUtil)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local TableUtil = require(Plugin.Src.Util.TableUtil)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy
local SetPointData = require(Plugin.Src.Actions.SetPointData)

return function(baseData, transformData, localSpace)
	return function(store)
		local state = store:getState()
		local cageData = state.cageData
		local pointTool = state.pointTool
		local status = state.status
		local selectItem = state.selectItem

		if status.toolMode ~= Constants.TOOL_MODE.Point then
			return
		end

		local editingCage = selectItem.editingCage
		local pointData = deepCopy(cageData.pointData)
		local selectedPoints = pointTool.selectedPoints
		local seamData = cageData.seamData
		local draggerType = status.draggerType

		for deformer, pointIndices in pairs(selectedPoints) do
			local rootCFrame = ModelUtil:getPartCFrame(deformer, editingCage)
			for pointIndex, weight in pairs(pointIndices) do
				local basePosition = baseData[editingCage][deformer][pointIndex].Position
				local result = ToolUtil:transformPoint(draggerType, weight, transformData, basePosition, rootCFrame, localSpace)

				pointData[editingCage][deformer][pointIndex].Position = result

				local linkedPointData = TableUtil:getNested(seamData, {editingCage, deformer, pointIndex})
				if linkedPointData then
					for _, linkedPoint in ipairs(linkedPointData) do
						local basePosition = baseData[editingCage][linkedPoint.Deformer][linkedPoint.Index].Position
						local linkedRootCFrame = ModelUtil:getPartCFrame(linkedPoint.Deformer, editingCage)
						local result = ToolUtil:transformPoint(draggerType, weight, transformData, basePosition, linkedRootCFrame, localSpace)
						pointData[editingCage][linkedPoint.Deformer][linkedPoint.Index].Position = result
					end
				end
			end
		end

		store:dispatch(SetPointData(pointData))
	end
end