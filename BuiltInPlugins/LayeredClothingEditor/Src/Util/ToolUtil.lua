local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Src.Util.Constants)
local MathUtil = require(Plugin.Src.Util.MathUtil)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local ToolUtil = {}

function ToolUtil:isDraggerPointMode(context)
	return context.toolMode == Constants.TOOL_MODE.Point
end

function ToolUtil:isDraggerRingMode(context)
	return context.toolMode == Constants.TOOL_MODE.Ring
end

function ToolUtil:isDraggerLatticeMode(context)
	return context.toolMode == Constants.TOOL_MODE.Lattice
end

function ToolUtil:createBasis(initialAxis, largestExtentAxis)
	local lookVector =  Vector3.new(0, 0, 1)
	local upVector = Vector3.new(0, 1, 0)
	local rightVector = Vector3.new(1, 0, 0)

	if largestExtentAxis == Enum.Axis.Z then
		lookVector = initialAxis
		upVector = MathUtil:fuzzyEq_Vector3(lookVector, upVector) and rightVector or upVector
		rightVector = lookVector:Cross(upVector)
		upVector = rightVector:Cross(lookVector)
	elseif largestExtentAxis == Enum.Axis.Y then
		upVector = initialAxis
		lookVector = MathUtil:fuzzyEq_Vector3(lookVector, upVector) and rightVector or lookVector
		rightVector = lookVector:Cross(upVector)
	else
		rightVector = initialAxis
		upVector = MathUtil:fuzzyEq_Vector3(rightVector, upVector) and rightVector or upVector
		upVector = rightVector:Cross(upVector)
	end

	return CFrame.fromMatrix(Vector3.new(0, 0, 0), rightVector, upVector)
end

function ToolUtil:getOrientationFromPoints(points, bounds)
	local center = bounds.Center
	local largestExtentAxis = bounds.LargestExtentAxis

	-- split verts into two groups based on distance from center
	local groupA = {}
	local groupB = {}
	for _, point in ipairs(points) do
		local pos = point.Position
		if largestExtentAxis == Enum.Axis.Z then
			if pos.Z >= center.Z then
				table.insert(groupA, pos)
			elseif pos.Z <= center.Z then
				table.insert(groupB, pos)
			end
		elseif largestExtentAxis == Enum.Axis.Y then
			if pos.Y >= center.Y then
				table.insert(groupA, pos)
			elseif pos.Y <= center.Y then
				table.insert(groupB, pos)
			end
		else
			if pos.X >= center.X then
				table.insert(groupA, pos)
			elseif pos.X <= center.X then
				table.insert(groupB, pos)
			end
		end
	end

	-- determine direction based on center of bounds of two groups of verts
	-- this isn't totally accurate but it's simple and close enough for our needs
	local boundsA = ModelUtil:getBounds(groupA)
	local boundsB = ModelUtil:getBounds(groupB)

	return (boundsA.Center - boundsB.Center).Unit
end

function ToolUtil:transformPoint(draggerType, weight, transformData, basePosition, rootCFrame, localSpace)
	local transform = transformData.transform
	local transformFrom = transformData.transformFrom

	local result = basePosition
	if draggerType == Enum.RibbonTool.Move then
		result = self:translatePoint(basePosition, transform, rootCFrame, weight)
	elseif draggerType == Enum.RibbonTool.Scale then
		result = self:scalePoint(basePosition, transform, transformFrom, rootCFrame, weight, localSpace)
	elseif draggerType == Enum.RibbonTool.Rotate then
		result = self:rotatePoint(basePosition, transform, transformFrom, rootCFrame, weight)
	end

	return result
end

function ToolUtil:translatePoint(position, transform, rootCFrame, weight)
	local weightedTransform = (transform - transform.p) + (transform.p * weight)
	return rootCFrame:inverse() * (weightedTransform * (rootCFrame * position))
end

function ToolUtil:scalePoint(position, scale, scaleFrom, rootCFrame, weight, localSpace)
	local weightedScale = Vector3.new(
		(1 - scale.X) * (1 - weight) + scale.X,
		(1 - scale.Y) * (1 - weight) + scale.Y,
		(1 - scale.Z) * (1 - weight) + scale.Z)

	if localSpace then
		local relativeToScaleCenter = scaleFrom:inverse() * (rootCFrame * position)
		return rootCFrame:inverse() * scaleFrom * (weightedScale * relativeToScaleCenter)
	else
		local relativeToScaleCenter = (rootCFrame * position) - scaleFrom.p
		return rootCFrame:inverse() * ((weightedScale * relativeToScaleCenter) + scaleFrom.p)
	end
end

function ToolUtil:rotatePoint(position, transform, pivot, rootCFrame, weight)
	local rotOnly = transform - transform.p
	local relativeToRotCenter = (rootCFrame * position) - pivot

	local newPos = rootCFrame:inverse() * ((rotOnly * relativeToRotCenter) + pivot)
	local weighted = position:Lerp(newPos, weight)
	return weighted
end

return ToolUtil