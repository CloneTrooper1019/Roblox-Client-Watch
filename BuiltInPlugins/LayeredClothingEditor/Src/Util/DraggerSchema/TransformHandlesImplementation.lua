local Plugin = script.Parent.Parent.Parent.Parent

local ToolUtil = require(Plugin.Src.Util.ToolUtil)

local TransformHandlesImplementation = {}
TransformHandlesImplementation.__index = TransformHandlesImplementation

function TransformHandlesImplementation.new(draggerContext)
	return setmetatable({
		_draggerContext = draggerContext,
	}, TransformHandlesImplementation)
end

--[[
	Start dragging the items in initialSelectionInfo.
]]
function TransformHandlesImplementation:beginDrag(selection, initialSelectionInfo)
	self._baseData = self._draggerContext.pointData
	self._baseLatticeData = self._draggerContext.latticeData
	local basis, center = initialSelectionInfo:getBoundingBox()
	self._baseBoundingBoxCenter = basis.p + center

	self._draggerContext.addWaypoint()
end

--[[
	Try to move the selection passed to beginDrag by a global transform relative
	to where it started, that is for each point p in the selection:
	  p' = globalTransform * p
	Then return that global transform that was actually applied.
]]
function TransformHandlesImplementation:updateDrag(globalTransform)
	local transformData = {
		transform = globalTransform,
		transformFrom = self._baseBoundingBoxCenter
	}

	if ToolUtil:isDraggerPointMode(self._draggerContext) then
		self._draggerContext.transformPoints(self._baseData, transformData, self._draggerContext:shouldUseLocalSpace())
	elseif ToolUtil:isDraggerLatticeMode(self._draggerContext) then
		self._draggerContext.transformLatticePoints(self._baseData, self._baseLatticeData, transformData, self._draggerContext:shouldUseLocalSpace())
	end
	return globalTransform
end

--[[
	Finish dragging the items.
]]
function TransformHandlesImplementation:endDrag()
	self._baseData = nil
	self._baseLatticeData = nil
	self._baseBoundingBoxCenter = nil
end

--[[
	Renders any snapping, joint, etc widgets that should show up while dragging.
	Returns: A Roact element.
]]
function TransformHandlesImplementation:render(currentBasisCFrame)
	return nil
end

return TransformHandlesImplementation