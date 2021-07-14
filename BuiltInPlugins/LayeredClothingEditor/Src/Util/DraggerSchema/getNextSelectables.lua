local Plugin = script.Parent.Parent.Parent.Parent

local ToolUtil = require(Plugin.Src.Util.ToolUtil)

return function(draggerContext, currentSelection, dragInfo, isDoubleClick)
	if isDoubleClick and ToolUtil:isDraggerPointMode(draggerContext) then
		local pointData = draggerContext.pointData
		local editingCage = draggerContext.editingCage

		if not pointData or not pointData[editingCage] then
			return
		end

		local lastPoint = currentSelection[#currentSelection]
		local deformer = lastPoint.Deformer

		local pointsPerDeformer = pointData[editingCage][deformer]
		for pointIndex in pairs(pointsPerDeformer) do
			table.insert(currentSelection, setmetatable({
				Deformer = deformer,
				Index = pointIndex,
			}, draggerContext.SelectedPointMeta))
		end
	end
	return currentSelection
end