local DraggerSchemaCore = script.Parent
local Packages = DraggerSchemaCore.Parent
local DraggerFramework = Packages.DraggerFramework

local TemporaryTransparency = require(DraggerFramework.Utility.TemporaryTransparency)
local getBoundingBoxScale = require(DraggerFramework.Utility.getBoundingBoxScale)
local PartMover = require(DraggerFramework.Utility.PartMover)
local AttachmentMover = require(DraggerFramework.Utility.AttachmentMover)
local getGeometry = require(DraggerFramework.Utility.getGeometry)

local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local TransformHandlesImplementation = {}
TransformHandlesImplementation.__index = TransformHandlesImplementation

-- The difference from exactly touching to try to bring a pair of parts within
-- when collisions are enabled.
-- After dragging one part into a collision with another one, the closest pair
-- of points P1 on the first part and P2 on the second part should satisfy:
-- (P1 - P2).Magnitude < TRANSFORM_COLLISION_THRESHOLD
local TRANSFORM_COLLISION_THRESHOLD = 0.0005

-- How far to snap the pivot when summoning the handles
local SUMMON_SNAP_THRESHOLD_PIXELS = 16

-- The center snap threshold is more generous since you can't easily tell where
-- the center is trying to snap to it blind (you don't see it highlighted while
-- attempting to snap to it)
local SUMMON_SNAP_CENTER_THRESHOLD_PIXELS = 20

function TransformHandlesImplementation.new(draggerContext, ikTransformFunction)
	return setmetatable({
		_draggerContext = draggerContext,
		_ikTransformFunction = ikTransformFunction,
		_partMover = PartMover.new(),
		_attachmentMover = AttachmentMover.new(),
	}, TransformHandlesImplementation)
end

--[[
	Start dragging the items in initialSelectionInfo.
]]
function TransformHandlesImplementation:beginDrag(selection, initialSelectionInfo)
	local partsToMove, attachmentsToMove, modelsToMove =
		initialSelectionInfo:getObjectsToTransform()

	self._initialSelectionInfo = initialSelectionInfo

	self._lastGoodGeometricTransform = CFrame.new()
	self._lastAppliedTransform = CFrame.new()
	self._hasPartsToMove = #partsToMove > 0
	local basisCFrame, offset
	basisCFrame, offset, self._boundingBoxSize =
		initialSelectionInfo:getBoundingBox()
	self._centerPoint = basisCFrame * CFrame.new(offset)

	local breakJoints = not self:_shouldSolveConstraints()
	self._partMover:setDragged(
		partsToMove,
		initialSelectionInfo:getOriginalCFrameMap(),
		breakJoints,
		self._centerPoint.Position,
		selection,
		modelsToMove)
	self._attachmentMover:setDragged(
		attachmentsToMove)

	if not self._draggerContext:areCollisionsEnabled() then
		self._temporaryTransparency = TemporaryTransparency.new(partsToMove)
	end
end

--[[
	Try to move the selection passed to beginDrag by a global transform relative
	to where it started, that is for each point p in the selection:
	  p' = globalTransform * p
	Then return that global transform that was actually applied.
]]
function TransformHandlesImplementation:updateDrag(globalTransform)
	if self:_shouldSolveConstraints() then
		return self:_transformInverseKinematics(globalTransform)
	else
		return self:_transformGeometric(globalTransform)
	end
end

--[[
	Finish dragging the items.
]]
function TransformHandlesImplementation:endDrag()
	if self._draggerContext:shouldJoinSurfaces() and self._jointPairs then
		self._jointPairs:createJoints()
	end
	self._jointPairs = nil
	self._partMover:commit()
	self._attachmentMover:commit()
	if self._temporaryTransparency then
		self._temporaryTransparency:destroy()
		self._temporaryTransparency = nil
	end
	
	-- Return an updated SelectionInfo to prevent the DraggerFramework from
	-- computing fresh one from scratch (it would do that by default if we
	-- did not return anything).
	-- The additional info we have lets us compute the new one more efficiently
	-- by deriving it from the old one based on the operation we did.
	return self._initialSelectionInfo:getTransformedCopy(self._lastAppliedTransform)
end

--[[
	Renders any snapping, joint, etc widgets that should show up while dragging.
	Returns: A Roact element.
]]
function TransformHandlesImplementation:render(globalTransform)
	local newCenterPoint = globalTransform
	if getFFlagSummonPivot() then
		newCenterPoint = globalTransform * self._centerPoint
	end
	if self._draggerContext:shouldJoinSurfaces() and self._jointPairs then
		local scale = getBoundingBoxScale(
			self._draggerContext, newCenterPoint, self._boundingBoxSize)
		return self._jointPairs:renderJoints(scale)
	else
		-- Don't render anything
		return nil
	end
end

--[[
	For direct geometric movement, move as a delta from the position the
	part started at on mouse down to reduce floating point error.
]]
function TransformHandlesImplementation:_transformGeometric(globalTransform)
	if globalTransform == self._lastGoodGeometricTransform then
		return globalTransform
	end

	-- Transform the parts, resolving collisions if needed
	local appliedTransform = self:_safelyTransformParts(
		self._lastGoodGeometricTransform, globalTransform)
	if self._draggerContext:shouldJoinSurfaces() then
		self._jointPairs = self._partMover:computeJointPairs(appliedTransform)
	end

	-- Attachments follow what the parts did
	self._attachmentMover:transformTo(appliedTransform)

	self._lastGoodGeometricTransform = appliedTransform
	self._lastAppliedTransform = appliedTransform
	return appliedTransform
end

--[[
	For inverse kinematics movement, always move in incremental steps
]]
function TransformHandlesImplementation:_transformInverseKinematics(globalTransform)
	local collisionsMode =
		self._draggerContext:areCollisionsEnabled() and
		Enum.IKCollisionsMode.IncludeContactedMechanisms or
		Enum.IKCollisionsMode.NoCollisions

	-- Transform the parts using IK
	local actualGlobalTransformUsed =
		self._ikTransformFunction(self._partMover, globalTransform, collisionsMode)
	if self._draggerContext:shouldJoinSurfaces() then
		self._jointPairs = self._partMover:computeJointPairs(actualGlobalTransformUsed)
	end

	-- Attachments follow what the parts did
	self._attachmentMover:transformTo(actualGlobalTransformUsed)
	self._lastAppliedTransform = actualGlobalTransformUsed

	return actualGlobalTransformUsed
end

local function cframesAreWithinThreshold(a, b, threshold)
	local dist = (a.Position - b.Position).Magnitude
	local rotation = math.max(
		(a.XVector - b.XVector).Magnitude,
		(a.YVector - b.YVector).Magnitude,
		(a.ZVector - b.ZVector).Magnitude)
	return dist < threshold and rotation < threshold, dist, rotation
end

function TransformHandlesImplementation:_toLocalTransform(globalTransform)
	return self._centerPoint:Inverse() * globalTransform * self._centerPoint
end
function TransformHandlesImplementation:_toGlobalTransform(localTransform)
	return self._centerPoint * localTransform * self._centerPoint:Inverse()
end

--[[
	Resolve collisions via a binary search between the last good delta and the
	currently desired delta. Assume that the last good delta is free, the
	desired delta is blocked, and there is a single point between the two where
	it switches between blocked and free.
	Return the good delta that we moved the parts to.
]]
function TransformHandlesImplementation:_safelyTransformParts(fromTransform, goalTransform)
	self._partMover:transformTo(goalTransform)

	-- Easy path if there are no collisions to resolve
	if not self._draggerContext:areCollisionsEnabled() or
		not self._partMover:isIntersectingOthers() then
		return goalTransform
	end

	-- We need the transforms in local space for them to lerp nicely
	local start = self:_toLocalTransform(fromTransform)
	local goal = self:_toLocalTransform(goalTransform)
	local isIntersecting = true
	local iterations = 0

	while not cframesAreWithinThreshold(start, goal, TRANSFORM_COLLISION_THRESHOLD) do
		local mid = start:Lerp(goal, 0.5)
		self._partMover:transformTo(self:_toGlobalTransform(mid))
		isIntersecting = self._partMover:isIntersectingOthers()
		if isIntersecting then
			goal = mid
		else
			start = mid
		end

		iterations += 1
		-- We should never need more than 32 iterations
		-- if we do it probably means there was a floating point error
		-- The safest thing to do in this case is to reset to the
		-- original position
		if iterations > 32 then
			start = self:_toLocalTransform(fromTransform)
			break
		end
	end

	-- Special case to not let us move very slightly and then stop. If we allow
	-- that then a translate which collides almost right away will produce no
	-- visible changes but introduce floating point error.
	-- The 2x is not a random fudge factor, it is precisely chosen: `goal` and
	-- `start` always bound the true collision point. After the loop, they are
	-- guaranteed to be within the threshold of eachother. We want to test
	-- whether the the move is within the threshold of zero. That means, at the
	-- very worst, the true collision point is at +threshold, and the loop
	-- exited at +threshold of the collision point, for a total of 2x threshold
	-- away from zero.
	if cframesAreWithinThreshold(start, CFrame.new(), TRANSFORM_COLLISION_THRESHOLD * 2) then
		start = CFrame.new()
		isIntersecting = true
	end

	local globalStart = self:_toGlobalTransform(start)

	-- Also don't allow us to move very slightly from the last move for the
	-- same reason as above, a very small move means we were already stopped at
	-- a good location but then overshot it.
	if cframesAreWithinThreshold(globalStart, fromTransform, TRANSFORM_COLLISION_THRESHOLD * 2) then
		globalStart = fromTransform
		isIntersecting = true
	end

	-- Have to make sure that we end on a non-intersection. The invariant is
	-- that start is the best safe position we've found, so we can move it.
	if isIntersecting then
		self._partMover:transformTo(globalStart)
	end

	-- Either we ended the loop on an intersection, and the above code moved us
	-- to start, or we ended on a non-intersect, in which case start is an
	-- up to date representation of the mid we last moved the parts to.
	return globalStart
end

function TransformHandlesImplementation:_shouldSolveConstraints()
	return self._draggerContext:areConstraintsEnabled() and self._hasPartsToMove
end

local function toVector2(vector3)
	return Vector2.new(vector3.X, vector3.Y)
end

-- When summoning the rotate, find a point to snap the temporary pivot to given
-- the hit geometry under the cursor.
function TransformHandlesImplementation:findSummonSnap(hitPoint, hitItem)
	if hitItem:IsA("Terrain") then
		return nil
	end

	local geometry = getGeometry(hitItem)
	if geometry.shape ~= "Mesh" then
		return nil
	end

	-- Find the face we hit
	local hitFace
	local hitDistance = math.huge
	for _, face in ipairs(geometry.faces) do
		local projection = math.abs((hitPoint - face.vertices[1]).Unit:Dot(face.normal))
		if projection < hitDistance then
			hitDistance = projection
			hitFace = face
		end
	end

	-- Are we close to any of the verts? (in screen space)
	local screenPoint = toVector2(self._draggerContext:worldToViewportPoint(hitPoint))
	local closestVertexInThreshold
	local closestVertexDist = SUMMON_SNAP_THRESHOLD_PIXELS
	for _, vertex in ipairs(hitFace.vertices) do
		local vertexOnScreen = toVector2(self._draggerContext:worldToViewportPoint(vertex))
		local distance = (vertexOnScreen - screenPoint).Magnitude
		if distance < closestVertexDist then
			closestVertexDist = distance
			closestVertexInThreshold = vertex
		end
	end
	if closestVertexInThreshold then
		return CFrame.fromMatrix(closestVertexInThreshold, hitFace.direction, hitFace.normal), true
	end

	-- Are we close to any of the edges? (in screen space)
	local closestEdgeInThreshold
	local closestEdgeDirection
	local closestEdgeDist = SUMMON_SNAP_THRESHOLD_PIXELS
	local vertexCount = #hitFace.vertices
	for i = 1, vertexCount do
		local v0 = hitFace.vertices[i]
		local v1 = hitFace.vertices[i % vertexCount + 1]
		local s0 = toVector2(self._draggerContext:worldToViewportPoint(v0))
		local s1 = toVector2(self._draggerContext:worldToViewportPoint(v1))
		local edgeDirection2D = (s1 - s0).Unit
		local toHit2D = (screenPoint - s0)
		local toPointOnEdge2D = edgeDirection2D * toHit2D:Dot(edgeDirection2D)
		local distance2D = (toHit2D - toPointOnEdge2D).Magnitude
		if distance2D < closestEdgeDist then
			closestEdgeDist = distance2D
			local edgeDirection = (v1 - v0).Unit
			local toHit = hitPoint - v0
			local toPointOnEdge = edgeDirection * toHit:Dot(edgeDirection)
			closestEdgeInThreshold = v0 + toPointOnEdge
			closestEdgeDirection = edgeDirection
		end
	end
	if closestEdgeInThreshold then
		return CFrame.fromMatrix(closestEdgeInThreshold, closestEdgeDirection, hitFace.normal), true
	end

	-- Are we close to the center?
	local mouseAt = self._draggerContext:getMouseLocation()
	local centerPoint = toVector2(self._draggerContext:worldToViewportPoint(hitItem.Position))
	if (mouseAt - centerPoint).Magnitude < SUMMON_SNAP_CENTER_THRESHOLD_PIXELS then
		return hitItem.CFrame, false
	end

	return nil
end

return TransformHandlesImplementation