--[[
	Thunk to calculate new transforms for lattice control points and their associated Rbf points
	whenever they are being manipulated by the draggers.
]]

local Plugin = script.Parent.Parent.Parent
local SetLatticeData = require(Plugin.Src.Actions.SetLatticeData)
local SetPointData = require(Plugin.Src.Actions.SetPointData)

local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy
local Constants = require(Plugin.Src.Util.Constants)
local ToolUtil = require(Plugin.Src.Util.ToolUtil)
local TableUtil = require(Plugin.Src.Util.TableUtil)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local function getTransformedPoints(latticeData, controlPoints)
	local affectedPoints = {}
	for _, controlPoint in pairs(controlPoints) do
		local deformer = controlPoint.Deformer
		local id = controlPoint.ID

		local cellIndices = latticeData[deformer].controlPointToCellMap[id]
		local foundCells = {}
		if cellIndices and #cellIndices > 0 then
			for _, cellIndex in ipairs(cellIndices) do
				table.insert(foundCells, latticeData[deformer].rbfPointsInCell[cellIndex])
			end
		end
		if #foundCells > 0 then
			for _, cell in ipairs(foundCells) do
				for point, weights in pairs(cell) do
					if not affectedPoints[point] then
						affectedPoints[point] = 0
					end
					affectedPoints[point] = affectedPoints[point] + weights[id]
				end
			end
		end
	end
	return affectedPoints
end

local function latticeGridHelper(lattice, gridPosition, func)
	local layersY = lattice[gridPosition.X]
	if layersY then
		local columnsZ = layersY[gridPosition.Y]
		if columnsZ then
			local latticeCell = columnsZ[gridPosition.Z]
			if latticeCell then
				return func(latticeCell)
			end
		end
	end
end

local function getControlPointPosition(lattice, gridPosition)
	return latticeGridHelper(lattice, gridPosition, function(cell)
		return cell.position
	end)
end

local function setControlPointPosition(lattice, gridPosition, value)
	latticeGridHelper(lattice, gridPosition, function(cell)
		cell.position = value
	end)
end

return function(baseData, baseLatticeData, transformData, localSpace)
	return function(store)

		local state = store:getState()
		local cageData = state.cageData
		local latticeTool = state.latticeTool
		local status = state.status
		local selectItem = state.selectItem

		if status.toolMode ~= Constants.TOOL_MODE.Lattice then
			return
		end

		local editingCage = selectItem.editingCage
		local latticeData = deepCopy(latticeTool.latticeData)
		local pointData = deepCopy(cageData.pointData)
		local selectedControlPoints = status.selectedControlPoints
		local selectedDeformer = latticeTool.selectedLattice
		local seamData = cageData.seamData
		local draggerType = status.draggerType

		if not selectedDeformer then
			return
		end

		-- Move the control points on the lattice
		local rootCFrame = ModelUtil:getPartCFrame(selectedDeformer, editingCage)
		for _, controlPoint in pairs(selectedControlPoints) do
			local deformer = controlPoint.Deformer
			local gridPosition = controlPoint.GridPosition

			local baseLattice = baseLatticeData[editingCage][deformer].lattice
			local pos = getControlPointPosition(baseLattice, gridPosition)

			local result = ToolUtil:transformPoint(draggerType, 1, transformData, pos, rootCFrame, localSpace)

			local lattice = latticeData[editingCage][deformer].lattice
			setControlPointPosition(lattice, gridPosition, result)
		end

		-- Move the cage mesh points affected by the lattice
		local affectedPoints = getTransformedPoints(latticeData[editingCage], selectedControlPoints)
		for pointIndex, weight in pairs(affectedPoints) do
			local basePosition = baseData[editingCage][selectedDeformer][pointIndex].Position
			local result = ToolUtil:transformPoint(draggerType, weight, transformData, basePosition, rootCFrame, localSpace)

			pointData[editingCage][selectedDeformer][pointIndex].Position = result
			local linkedPointData = TableUtil:getNested(seamData, {editingCage, selectedDeformer, pointIndex})
			if linkedPointData then
				for _, linkedPoint in ipairs(linkedPointData) do
					local basePosition = baseData[editingCage][linkedPoint.Deformer][linkedPoint.Index].Position
					local linkedRootCFrame = ModelUtil:getPartCFrame(linkedPoint.Deformer, editingCage)
					local result = ToolUtil:transformPoint(draggerType, weight, transformData, basePosition, linkedRootCFrame, localSpace)
					pointData[editingCage][linkedPoint.Deformer][linkedPoint.Index].Position = result
				end
			end
		end

		store:dispatch(SetPointData(pointData))
		store:dispatch(SetLatticeData(latticeData))
	end
end