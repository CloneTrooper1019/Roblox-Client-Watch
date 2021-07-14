local Plugin = script.Parent.Parent.Parent

local SetSeamData = require(Plugin.Src.Actions.SetSeamData)

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local TableUtil = require(Plugin.Src.Util.TableUtil)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy

local MULTIPLIER = 100

local function findSeams(points, deformer, editingCage, otherDeformer, otherPoints, seamData)
	local roundedValues = {}
	local sameSet = deformer == otherDeformer
	for index, point in pairs(points) do
		local partCFrame = ModelUtil:getPartCFrame(deformer, editingCage)
		local position = partCFrame * point.Position
		local x = math.floor(position.X * MULTIPLIER)
		local y = math.floor(position.Y * MULTIPLIER)
		local z = math.floor(position.Z * MULTIPLIER)

		if not roundedValues[x] then roundedValues[x] = {} end
		if not roundedValues[x][y] then roundedValues[x][y] = {} end
		if not roundedValues[x][y][z] then roundedValues[x][y][z] = {} end

		table.insert(roundedValues[x][y][z], index)
	end

	for otherIndex, otherPoint in pairs(otherPoints) do
		local otherPartCFrame = ModelUtil:getPartCFrame(otherDeformer, editingCage)
		local position = otherPartCFrame * otherPoint.Position
		local x = math.floor(position.X * MULTIPLIER)
		local y = math.floor(position.Y * MULTIPLIER)
		local z = math.floor(position.Z * MULTIPLIER)

		local matches = roundedValues[x] and roundedValues[x][y] and roundedValues[x][y][z]
		if matches then
			for _, index in ipairs(matches) do
				if not sameSet or (sameSet and index ~= otherIndex) then
					TableUtil:insertNested(seamData, {deformer, index}, {
						Index = otherIndex,
						Deformer = otherDeformer,
					})
					TableUtil:insertNested(seamData, {otherDeformer, otherIndex}, {
						Index = index,
						Deformer = deformer,
					})
				end
			end
		end
	end
end

return function(editingCage)
	return function(store)
		local state = store:getState()
		local pointData = state.cageData.pointData
		if not pointData then
			return
		end

		local seamData = state.cageData.seamData
		if not seamData then
			seamData = {}
		else
			seamData = deepCopy(seamData)
		end
		seamData[editingCage] = {}
		local seamDataForCage = seamData[editingCage]

		for deformer in pairs(pointData[editingCage]) do
			local connectedDeformer = ModelUtil:getConnectedDeformer(deformer)
			local points = pointData[editingCage][deformer]
			if connectedDeformer then
				local connectedPoints = pointData[editingCage][connectedDeformer]
				findSeams(points, deformer, editingCage, connectedDeformer, connectedPoints, seamDataForCage)
			end
			findSeams(points, deformer, editingCage, deformer, points, seamDataForCage)
		end
		store:dispatch(SetSeamData(seamData))
	end
end