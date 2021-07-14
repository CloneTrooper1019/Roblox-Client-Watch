local Plugin = script.Parent.Parent.Parent

local SetLatticeData = require(Plugin.Src.Actions.SetLatticeData)
local SetLatticeBoundsData = require(Plugin.Src.Actions.SetLatticeBoundsData)

local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local deepJoin = Util.deepJoin
local deepCopy = Util.deepCopy

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local ToolUtil = require(Plugin.Src.Util.ToolUtil)

local function validCellCorners(cell)
	local count = 0
	for _, value in pairs(cell) do
		if value ~= nil then
			count = count + 1
		end
	end
	-- 8 corner points in a lattice cell
	return count == 8
end

local function getPointsInCell(cell, points)
	local cellRbfPoints = {}
	local cellWidth = (cell[1].position - cell[2].position).Magnitude
	local cellHeight = (cell[1].position - cell[3].position).Magnitude
	local cellDepth = (cell[1].position - cell[5].position).Magnitude
	for index, point in ipairs(points) do
		local inX = point.Position.X >= cell[1].position.X and point.Position.X <= cell[2].position.X
		local inY = point.Position.Y >= cell[2].position.Y and point.Position.Y <= cell[3].position.Y
		local inZ = point.Position.Z >= cell[1].position.Z and point.Position.Z <= cell[5].position.Z
		if inX and inY and inZ then
			cellRbfPoints[index] = {}
			for _, cellCorner in pairs(cell) do
				local cpToPoint = point.Position - cellCorner.position
				local xWeight =  1 - math.clamp(math.abs(cpToPoint.X) / cellWidth, 0, 1)
				local yWeight = 1 - math.clamp(math.abs(cpToPoint.Y) / cellHeight, 0, 1)
				local zWeight = 1 - math.clamp(math.abs(cpToPoint.Z) / cellDepth, 0, 1)

				cellRbfPoints[index][cellCorner.id] = xWeight * yWeight * zWeight
			end
		end
	end
	return cellRbfPoints
end

local function buildLatticeStructure(deformer, subdivisions, bounds)
	local offsety = bounds.Height / subdivisions.Y
	local offsetx = bounds.Width / subdivisions.X
	local offsetz = bounds.Depth / subdivisions.Z
	local startPoint = bounds.Bottom.Front.Left

	local latticePoints = {}
	for i = 1, (subdivisions.Y + 1) do
		latticePoints[i] = {}
		for j = 1, (subdivisions.Z + 1) do
			latticePoints[i][j] = {}
			for k = 1, (subdivisions.X + 1) do
				table.insert(latticePoints[i][j], {
					id = deformer ..i ..j ..k,
					position =  startPoint + Vector3.new(offsetx * (k - 1), offsety * (i - 1), offsetz * (j - 1))
				})
			end
		end
	end
	return latticePoints
end

local function getLocalBoundsData(state, editingCage, deformer, originalBounds)
	local pointData = state.cageData.pointData

	local rootCFrame = ModelUtil:getPartCFrame(deformer, editingCage)
	local pointsPerDeformer = pointData[editingCage][deformer]

	local direction = ToolUtil:getOrientationFromPoints(pointsPerDeformer, originalBounds)
	local transform = ToolUtil:createBasis(direction, originalBounds.LargestExtentAxis)

	local orientedPoints = deepCopy(pointData[editingCage][deformer])
	for _, point in pairs(orientedPoints) do
		point.Position = transform:inverse() * point.Position
	end

	local newBounds = ModelUtil:getBounds(orientedPoints)
	newBounds.Center = originalBounds.Center
	newBounds.CFrame = transform + originalBounds.Center

	return {
		Bounds = newBounds,
		Points = orientedPoints,
		Transform = transform,
		Root = rootCFrame,
		Offset = newBounds.Center + Vector3.new(-newBounds.Width / 2, -newBounds.Height / 2, -newBounds.Depth /2) - newBounds.Bottom.Front.Left
	}
end

local function fixupBounds(latticePoints, bounds, transform, rootCFrame, offset)
	for _, zLayers in pairs(latticePoints) do
		for _, xLayers in pairs(zLayers) do
			for _, latticePoint in pairs(xLayers) do
				local position = latticePoint.position + offset
				local pivot = rootCFrame.p + bounds.Center
				local relativeToRotCenter = rootCFrame.p + position - pivot
				latticePoint.position = (transform * relativeToRotCenter) + pivot - rootCFrame.p
			end
		end
	end

	local gridHeight = #latticePoints
	local gridDepth = #latticePoints[1]
	local gridWidth = #latticePoints[1][1]

	bounds.Top = {
		Front = {
			Left = latticePoints[gridHeight][1][1],
			Right = latticePoints[gridHeight][1][gridWidth],
		},
		Back = {
			Left = latticePoints[gridHeight][gridDepth][1],
			Right = latticePoints[gridHeight][gridDepth][gridWidth],
		},
	}
	bounds.Bottom = {
		Front = {
			Left = latticePoints[1][1][1],
			Right = latticePoints[1][1][gridWidth],
		},
		Back = {
			Left = latticePoints[1][gridDepth][1],
			Right = latticePoints[1][gridDepth][gridWidth],
		},
	}
end

local function sortRbfPointsIntoCells(latticeData, points, editingCage, deformer)
	local rbfPointsInCell = latticeData[editingCage][deformer].rbfPointsInCell
	local controlPointToCellMap = latticeData[editingCage][deformer].controlPointToCellMap
	local latticePoints = latticeData[editingCage][deformer].lattice

	for i = 1, #latticePoints do
		local layer = latticePoints[i]
		local nextLayer = latticePoints[i + 1]
		if layer and nextLayer then
			for j = 1, #layer do
				local row = layer[j]
				local nextRow = layer[j + 1]
				local nextLayerRow = nextLayer[j]
				local nextLayerNextRow = nextLayer[j + 1]
				if row and nextRow and nextLayerRow and nextLayerNextRow then
					for k = 1, #row do
						local cellCorners = {
							row[k], row[k + 1], nextLayerRow[k],
							nextLayerRow[k + 1], nextRow[k], nextRow[k + 1],
							nextLayerNextRow[k], nextLayerNextRow[k + 1]
						}
						if validCellCorners(cellCorners) then
							table.insert(rbfPointsInCell, getPointsInCell(cellCorners, points))
							for _, cellCorner in pairs(cellCorners) do
								if not controlPointToCellMap[cellCorner.id] then
									controlPointToCellMap[cellCorner.id] = {}
								end
								table.insert(controlPointToCellMap[cellCorner.id], #rbfPointsInCell)
							end
						end
					end
				end
			end
		end
	end
end

return function(deformer, editingCage, localAlignment)
	return function(store)
		local state = store:getState()

		local subdivisions = state.latticeTool.subdivisions
		local latticeBoundsData = state.latticeTool.latticeBoundsData
		local pointData = state.cageData.pointData

		if not pointData then
			return
		end

		local latticeData = state.latticeTool.latticeData
		local latticeDataCopy = deepCopy(latticeData)
		if not latticeDataCopy[editingCage] then
			latticeDataCopy[editingCage] = {}
		end

		if not pointData[editingCage] or not pointData[editingCage][deformer] then
			return
		end

		local points = pointData[editingCage][deformer]
		local bounds = ModelUtil:getBounds(points)
		local subdivision = subdivisions[editingCage][deformer]

		local localData
		if localAlignment then
			localData = getLocalBoundsData(state, editingCage, deformer, bounds)
			points = localData.Points
			bounds = localData.Bounds
		end

		latticeBoundsData = deepJoin(latticeBoundsData, {
			[editingCage] = {
				[deformer] = bounds
			}
		})

		latticeDataCopy[editingCage][deformer] = {
			rbfPointsInCell = {},
			controlPointToCellMap = {},
			lattice = buildLatticeStructure(deformer, subdivision, bounds),
		}

		sortRbfPointsIntoCells(latticeDataCopy, points, editingCage, deformer)

		if localAlignment then
			local latticePoints = latticeDataCopy[editingCage][deformer].lattice
			fixupBounds(latticePoints, localData.Bounds, localData.Transform, localData.Root, localData.Offset)
		end

		store:dispatch(SetLatticeBoundsData(latticeBoundsData))
		store:dispatch(SetLatticeData(latticeDataCopy))
	end
end