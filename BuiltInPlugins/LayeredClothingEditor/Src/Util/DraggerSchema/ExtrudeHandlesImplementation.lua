local Plugin = script.Parent.Parent.Parent.Parent

local ToolUtil = require(Plugin.Src.Util.ToolUtil)

local ExtrudeHandlesImplementation = {}
ExtrudeHandlesImplementation.__index = ExtrudeHandlesImplementation

function ExtrudeHandlesImplementation.new(draggerContext)
	return setmetatable({
		_draggerContext = draggerContext,
	}, ExtrudeHandlesImplementation)
end

function ExtrudeHandlesImplementation:getBoundingBox(selection, selectionInfo)
	return selectionInfo:getBoundingBox()
end

-- Should the tool act as an actual scale tool (scaling around the basis
-- CFrame), or scale by moving the edge of the bounding box?
function ExtrudeHandlesImplementation:shouldScaleFromCenter(selection, selectionInfo, normalId)
	return true
end

function ExtrudeHandlesImplementation:shouldKeepAspectRatio(selection, selectionInfo, normalId)
	return self._draggerContext:isCtrlKeyDown()
end

function ExtrudeHandlesImplementation:axesToScale(selectionInfo, normalId)
	if self._draggerContext:isCtrlKeyDown() then
		return {X = true, Y = true, Z = true}
	end
	local axes = {{X = true}, {Y = true}, {Z = true}}
	return axes[normalId]
end

function ExtrudeHandlesImplementation:getMinimumSize(selection, selectionInfo, normalId)
	return Vector3.new(0, 0, 0)
end

function ExtrudeHandlesImplementation:beginScale(selection, initialSelectionInfo, normalId)
	self._baseData = self._draggerContext.pointData
	self._baseLatticeData = self._draggerContext.latticeData
	local basis, center, size = initialSelectionInfo:getBoundingBox()
	self._baseBoundingBoxSize = size
	self._baseBoundingBox = basis + center

	self._draggerContext.addWaypoint()
end

function ExtrudeHandlesImplementation:getMinMaxSizes(selectionInfo, axesToScale, bounds)
	local minimumAllowableSize = Vector3.new(0, 0, 0)
	local maximumAllowableSize = Vector3.new(1, 1, 1) * math.huge
	return minimumAllowableSize, maximumAllowableSize
end
-- Scale / Offset the selection by some local offset relative to the
-- initialSelectionInfo's basisCFrame. Also takes the new size of the bounding
-- box for convinience, though you may not need this.
function ExtrudeHandlesImplementation:updateScale(localDeltaSize, localOffset)
	local newBounds = self._baseBoundingBoxSize + localDeltaSize
	local scaleX = self._baseBoundingBoxSize.X ~= 0 and (newBounds.X / self._baseBoundingBoxSize.X) or 1
	local scaleY = self._baseBoundingBoxSize.Y ~= 0 and (newBounds.Y / self._baseBoundingBoxSize.Y) or 1
	local scaleZ = self._baseBoundingBoxSize.Z ~= 0 and (newBounds.Z / self._baseBoundingBoxSize.Z) or 1
	local scale = Vector3.new(scaleX, scaleY, scaleZ)

	local transformData = {
		transform = scale,
		transformFrom = self._baseBoundingBox
	}

	if ToolUtil:isDraggerPointMode(self._draggerContext) then
		self._draggerContext.transformPoints(self._baseData, transformData, self._draggerContext:shouldUseLocalSpace())
	elseif ToolUtil:isDraggerLatticeMode(self._draggerContext) then
		self._draggerContext.transformLatticePoints(self._baseData, self._baseLatticeData, transformData, self._draggerContext:shouldUseLocalSpace())
	end
	return localDeltaSize, localOffset
end

function ExtrudeHandlesImplementation:endScale()
	self._baseData = nil
	self._baseLatticeData = nil
	self._baseBoundingBoxSize = nil
	self._baseBoundingBox = nil
end

function ExtrudeHandlesImplementation:render(localDeltaSize, localOffset)
	return nil
end

return ExtrudeHandlesImplementation