
local DraggerSchemaCore = script.Parent
local Packages = DraggerSchemaCore.Parent
local DraggerFramework = Packages.DraggerFramework

local JointMaker = require(DraggerFramework.Utility.JointMaker)
local getBoundingBoxScale = require(DraggerFramework.Utility.getBoundingBoxScale)
local TemporaryTransparency = require(DraggerFramework.Utility.TemporaryTransparency)
local Math = require(DraggerFramework.Utility.Math)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)

local getFFlagSimPartVisualSize = require(DraggerFramework.Flags.getFFlagSimPartVisualSize)

local EMPTY_CFRAME = CFrame.new()
local ZERO_VECTOR = Vector3.new()
local ONES_VECTOR = Vector3.new(1, 1, 1)
local HUGE_VECTOR = ONES_VECTOR * math.huge

-- controls how large/small a part may be on any dimension
local MIN_PART_SIZE = 0.05
local MAX_PART_SIZE = 2048.0

local ExtrudeHandlesImplementation = {}
ExtrudeHandlesImplementation.__index = ExtrudeHandlesImplementation

function ExtrudeHandlesImplementation.new(draggerContext)
	return setmetatable({
		_draggerContext = draggerContext,
		_jointMaker = JointMaker.new(),
	}, ExtrudeHandlesImplementation)
end


-- The difference from exactly touching to try to bring a pair of parts within
-- when collisions are enabled.
-- After resizing one part into a collision with another one, the closest pair
-- of points P1 on the first part and P2 on the second part should satisfy:
-- (P1 - P2).Magnitude < RESIZE_COLLISION_THRESHOLD
-- Note: This is a deliberately looser threshold than the transform one, so that
-- after resizing parts into a collision, they can still be moved.
local RESIZE_COLLISION_THRESHOLD = 0.001

-- This function can just be `return selectionInfo:getBoundingBox()` unless you
-- need some special behavior.
function ExtrudeHandlesImplementation:getBoundingBox(selection, selectionInfo)
	-- When we only have one part selected, we're in extrude scaling mode,
	-- which can only be done in local space.
	local partsToResize, _ = selectionInfo:getObjectsToTransform()
	if #partsToResize == 1 then
		return selectionInfo:getLocalBoundingBox()
	else
		if getEngineFeatureModelPivotVisual() then
			local cframe, offset, size = selectionInfo:getBoundingBox()
			-- Modify the bounds to include the basis point ((0, 0, 0) in the
			-- space of the basis is the basis point)
			local halfSize = 0.5 * size
			local modifiedBoundsMin = (offset - halfSize):Min(ZERO_VECTOR)
			local modifiedBoundsMax = (offset + halfSize):Max(ZERO_VECTOR)
			size = (modifiedBoundsMax - modifiedBoundsMin)
			offset = (modifiedBoundsMax + modifiedBoundsMin) / 2
			return cframe, offset, size
		else
			return selectionInfo:getBoundingBox()
		end
	end
end

-- Should the tool act as an actual scale tool (scaling around the basis
-- CFrame), or scale by moving the edge of the bounding box?
function ExtrudeHandlesImplementation:shouldScaleFromCenter(selection, selectionInfo, normalId)
	return self._draggerContext:isCtrlKeyDown()
end

-- If FFlagLimitScaling is enabled, this function is no longer used
-- as it is replaced by :axesToScale(...)
function ExtrudeHandlesImplementation:shouldKeepAspectRatio(selection, selectionInfo, normalId)
	if self._draggerContext:isShiftKeyDown() then
		return true
	end
	local partsToResize, _ = selectionInfo:getObjectsToTransform()
	if #partsToResize == 1 then
		local part = partsToResize[1]
		if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
			return true
		end
		if part:IsA("UnionOperation") or part:IsA("NegateOperation") then
			return true
		end
		return false
	else
		return true
	end
end

function ExtrudeHandlesImplementation:axesToScale(selectionInfo, normalId)
	local ALL_AXES = {X = true, Y = true, Z = true}
	-- UX: shift key forces equal aspect ratio scaling
	if self._draggerContext:isShiftKeyDown() then
		return ALL_AXES
	end
	local partsToResize, _ = selectionInfo:getObjectsToTransform()
	-- multiple parts are only scaled with equal aspect ratio
	if #partsToResize ~= 1 then
		return ALL_AXES
	end
	local part = partsToResize[1]
	if part:IsA("Part") and part.Shape == Enum.PartType.Ball then
		-- special case: sphere only scales uniformly
		return ALL_AXES
	elseif  part:IsA("UnionOperation") or part:IsA("NegateOperation") then
		-- special case: CSG operations are treated the same way as multiple parts
		return ALL_AXES
	elseif part:IsA("Part") and part.Shape == Enum.PartType.Cylinder then
		-- assuming the axis of the cylinder is the X axis, allow increasing the height only
		-- but the base must scale proportionately in both directions
		return normalId == 1 and {X = true} or {Y = true, Z = true}
	end
	-- everything else is considered a regular single part, and can be scaled along one axis
	-- without keeping aspect ratio
	local axes = {{X = true}, {Y = true}, {Z = true}}
	return axes[normalId]
end

-- If FFlagLimitScaling is enabled, this function is no longer used
-- as it is replaced by :getMinMaxSizes()
--[[
	Find the smallest extents size that assures that all parts are larger
	than the minimum allowed part size.

	Resizing Cases:
	Suppose you have a part 5.5 studs long and a grid snap of 2
	 * You should be able to resize it down to 1.5 (5.5 % 2)
	Suppose you have a part 4 studs long and a grid snap of 2
	 * You should be able to resize it down to 2
	 * You should NOT be able to resize it down to 0 or MIN_PART_SIZE (It should
	   stop resizing at 2)
	Suppose you have a part 2.02 studs long and grid snap of 2
	 * You should NOT be able to resize it down to 0.02 (< MIN_PART_SIZE)
]]
function ExtrudeHandlesImplementation:getMinimumSize(selection, selectionInfo, normalId)
	local partsToResize = selectionInfo:getObjectsToTransform()
	local boundsCFrame, boundsOffset, boundsSize = self:getBoundingBox(selection, selectionInfo)

	local MIN_PART_SIZE = 0.05
	if getFFlagSimPartVisualSize() then
		MIN_PART_SIZE = 0.001
	end
	if #partsToResize == 1 then
		-- The modulo covers resizing down to smaller than the initial size in
		-- gridSize increments.
		local gridSizeValue = self._draggerContext:getGridSize()
		local partSize = partsToResize[1].Size
		local xmod = partSize.X % gridSizeValue
		local ymod = partSize.Y % gridSizeValue
		local zmod = partSize.Z % gridSizeValue

		-- This handles the edge case of trying to resize down to zero from an
		-- even multiple of the grid size.
		local modSize = Vector3.new(
			xmod > 0 and xmod or gridSizeValue,
			ymod > 0 and ymod or gridSizeValue,
			zmod > 0 and zmod or gridSizeValue)

		-- This Max call handles the resizing down to less than MIN_PART_SIZE
		-- but still greater than zero edge case.
		local hardMinSize = Vector3.new(MIN_PART_SIZE, MIN_PART_SIZE, MIN_PART_SIZE)
		return hardMinSize:Max(modSize)
	else
		local smallest = math.huge
		local minimumSize
		for _, part in ipairs(partsToResize) do
			local size = part.Size
			local minLength = math.min(size.X, size.Y, size.Z)
			if minLength < smallest then
				smallest = minLength
				local sizeRatio = minLength / MIN_PART_SIZE
				minimumSize = boundsSize / sizeRatio
			end
		end

		-- Make sure that the resized normal of the part is at least as
		-- large as the grid size.
		local minSizeComponents =
			{minimumSize.X, minimumSize.Y, minimumSize.Z}
		local sizeRatio = minSizeComponents[normalId] / self._draggerContext:getGridSize()
		if sizeRatio < 1 then
			minimumSize = minimumSize / sizeRatio
		end

		-- Finally, we CAN still resize down to less than the grid size if
		-- we started out smaller than the grid size.
		return minimumSize:Min(boundsSize)
	end
end

--[[
	Find the min/max sizes the selection can be scaled to that ensure 
	that all parts have sizes between MIN_PART_SIZE and MAX_PART_SIZE in all dimensions.
]]
function ExtrudeHandlesImplementation:getMinMaxSizes(selectionInfo, axesToScale, bounds)
	if getFFlagSimPartVisualSize() then
		MIN_PART_SIZE = 0.001
	end
	local axesVec = Math.setToVector3(axesToScale)
	-- this vector has 0 for axes along which we scale, and a huge number elsewhere
	local ignoredAxesVec = (ONES_VECTOR - axesVec) * MAX_PART_SIZE * 10
	local partsToResize = selectionInfo:getObjectsToTransform()
	local sizeMax = ZERO_VECTOR
	local sizeMin = HUGE_VECTOR
	local LOCAL_MAX_PART_SIZE = MAX_PART_SIZE
	local LOCAL_MIN_PART_SIZE = MIN_PART_SIZE
	-- special behavior for scaling a single truss part :(
	-- if trusses are a part of a group, ignore them
	if #partsToResize == 1 and partsToResize[1]:IsA("TrussPart") then
		LOCAL_MAX_PART_SIZE = 64
		LOCAL_MIN_PART_SIZE = 2
	end
	for _, part in ipairs(partsToResize) do
		sizeMax = sizeMax:Max(part.Size)
		sizeMin = sizeMin:Min(part.Size)
	end
	-- ignore axes that are not scaled by making them +/- huge
	local largestScaledDimension = Math.maxComponent(sizeMax - ignoredAxesVec)
	local smallestScaledDimension = Math.minComponent(sizeMin + ignoredAxesVec)
	local maxRatio = LOCAL_MAX_PART_SIZE / largestScaledDimension
	local minRatio = LOCAL_MIN_PART_SIZE / smallestScaledDimension
	-- Make sure the largest dimension of ANY part is between MIN_PART_SIZE and MAX_PART_SIZE after scaling along the given axes
	-- Leave other axes as they are.
	local maximumAllowableSize = bounds:Max(maxRatio * bounds - ignoredAxesVec)
	local minimumAllowableSize = bounds:Min(minRatio * bounds + ignoredAxesVec)
	return minimumAllowableSize, maximumAllowableSize
end

function ExtrudeHandlesImplementation:beginScale(selection, initialSelectionInfo, normalId)
	local boundsCFrame, boundsOffset, boundsSize =
		self:getBoundingBox(selection, initialSelectionInfo)
		
	self._originalBoundingBoxSize = boundsSize
	self._originalBoundingBoxCFrame = boundsCFrame * CFrame.new(boundsOffset)

	self._originalCFrameMap = initialSelectionInfo:getOriginalCFrameMap()
	self._partsToResize, self._attachmentsToMove, self._modelsToResize =
		initialSelectionInfo:getObjectsToTransform()

	self._originalSizeMap = {}
	for _, part in ipairs(self._partsToResize) do
		self._originalSizeMap[part] = part.Size
	end

	self._lastDeltaSize = Vector3.new(0, 0, 0)
	self._jointMaker:pickUpParts(self._partsToResize)
	self._jointMaker:anchorParts()
	self._jointMaker:breakJointsToOutsiders()
	self._jointMaker:disconnectInternalJoints()

	self:_recordItemsToFixup(self._partsToResize, self._modelsToResize)

	if not self._draggerContext:areCollisionsEnabled() then
		self._temporaryTransparency = TemporaryTransparency.new(self._partsToResize)
	end
end

local function roundDownIfClose(value, gridSize, threshold)
	local snapped = math.floor(value / gridSize) * gridSize
	if value - snapped < threshold then
		return snapped
	else
		return value
	end
end

-- If the part size is almost (within RESIZE_COLLISION_THRESHOLD) aligned to the
-- grid size, then snap it exactly back to the grid size, to allow parts which
-- somehow gained a floating point error in their size to return to being sized
-- exactly on grid. Note: We can only round down because rounding up may bring
-- the part into collision with something it wasn't before.
function ExtrudeHandlesImplementation:_maybeSnapPartSizeBackDownToGrid(size)
	local gridSize = self._draggerContext:getGridSize()
	return Vector3.new(
		roundDownIfClose(size.X, gridSize, RESIZE_COLLISION_THRESHOLD),
		roundDownIfClose(size.Y, gridSize, RESIZE_COLLISION_THRESHOLD),
		roundDownIfClose(size.Z, gridSize, RESIZE_COLLISION_THRESHOLD))
end

local function largestComponent(vector)
	return math.min(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

local function getFraction(lastSizeDelta, thisSizeDelta)
	local maxLast = largestComponent(lastSizeDelta)
	local maxThis = largestComponent(thisSizeDelta)
	if maxThis == 0 then
		return 0
	else
		return maxLast / maxThis
	end
end

-- Scale / offset the selection by some local offset relative to the
-- initialSelectionInfo's basisCFrame. Also takes the new size of the bounding
-- box for convenience, though you may not need this.
function ExtrudeHandlesImplementation:updateScale(localDeltaSize, localOffset)
	local doResize
	local lastOffset = localOffset

	if #self._partsToResize == 1 then
		local part = self._partsToResize[1]
		local originalSize = self._originalSizeMap[part]
		local originalCFrame = self._originalCFrameMap[part]

		function doResize(frac)
			self._lastDeltaSize = localDeltaSize * frac
			part.Size = originalSize + self._lastDeltaSize
			lastOffset = localOffset * frac
			part.CFrame = originalCFrame * CFrame.new(lastOffset)
		end
	else
		local originalCFrame = self._originalBoundingBoxCFrame
		local originalSize = self._originalBoundingBoxSize
		local center = originalCFrame.Position

		local globalOffset = originalCFrame:VectorToWorldSpace(localOffset)
		local totalScale =
			(originalSize + localDeltaSize).Magnitude / originalSize.Magnitude

		-- Precalculate the offsets to apply while scaling
		local totalOffsetForPartMap = {}
		for _, part in ipairs(self._partsToResize) do
			local originalPartPosition = self._originalCFrameMap[part].Position
			local offsetFromCenter = originalPartPosition - center
			totalOffsetForPartMap[part] = globalOffset + offsetFromCenter * (totalScale - 1)
		end

		function doResize(frac)
			self._lastDeltaSize = localDeltaSize * frac
			lastOffset = localOffset * frac
			local scale = 1 + frac * (totalScale - 1)
			local scaleVector = Vector3.new(scale, scale, scale)
			for part, totalOffset in pairs(totalOffsetForPartMap) do
				part.CFrame = self._originalCFrameMap[part] + totalOffset * frac
				part.Size = self._originalSizeMap[part] * scaleVector
			end
		end
	end

	if self._draggerContext:areCollisionsEnabled() then
		local initialFraction = getFraction(self._lastDeltaSize, localDeltaSize)
		local targetFraction = 1.0
		local includeInitiallyTouching = true
		local threshold =
			RESIZE_COLLISION_THRESHOLD / math.max(largestComponent(localDeltaSize), 1)
		self:_binarySearchForGoodPartSize(doResize,
			initialFraction,
			targetFraction,
			includeInitiallyTouching,
			threshold)
	else
		doResize(1.0)
	end

	-- Try to fix up floating point error on parts which are very close to the
	-- grid size.
	if #self._partsToResize == 1 then
		local thePart = self._partsToResize[1]
		thePart.Size = self:_maybeSnapPartSizeBackDownToGrid(thePart.Size)
	end

	-- Fixup stuff like meshes / constraint lengths
	local appliedScale =
		(self._originalBoundingBoxSize + self._lastDeltaSize) / self._originalBoundingBoxSize

	self:_applyFixup(appliedScale, lastOffset)
	self._jointMaker:fixupConstraintLengths()

	if self._draggerContext:shouldJoinSurfaces() then
		self._jointPairs = self._jointMaker:computeJointPairs()
	end

	return self._lastDeltaSize, lastOffset
end

function ExtrudeHandlesImplementation:endScale()
	self._originalSizeMap = {}

	if self._jointPairs then
		self._jointPairs:createJoints()
		self._jointPairs = nil
	end

	local appliedScale = getFraction(
		self._originalBoundingBoxSize + self._lastDeltaSize,
		self._originalBoundingBoxSize)
	self._jointMaker:reconnectInternalJointsWithScale(appliedScale)
	self._jointMaker:restoreAnchored()
	self._jointMaker:putDownParts()

	if self._temporaryTransparency then
		self._temporaryTransparency:destroy()
		self._temporaryTransparency = nil
	end
end

function ExtrudeHandlesImplementation:render(localDeltaSize, localOffset)
	if self._draggerContext:shouldJoinSurfaces() and self._jointPairs then
		local cframe = self._originalBoundingBoxCFrame * CFrame.new(localOffset)
		local size = self._originalBoundingBoxSize + localDeltaSize
		local scale = getBoundingBoxScale(self._draggerContext, cframe, size)
		return self._jointPairs:renderJoints(scale)
	else
		return nil
	end
end

--[[
	Finds the maximum value resizeFunction can be called with (called with a
	fraction between initialFraction and targetFraction) without any of the
	_jointMaker's parts colliding with other parts.
	If includeInitiallyTouching is false then collisions with parts it was
	colliding with to begin with are ignored.
]]
function ExtrudeHandlesImplementation:_binarySearchForGoodPartSize(
	resizeFunction, initialFraction, targetFraction, includeInitiallyTouching, threshold)
	-- Early out, can we resize right to the target?
	resizeFunction(targetFraction)
	local lastIterationHadCollision = self._jointMaker:isColliding(includeInitiallyTouching)
	if not lastIterationHadCollision then
		return
	end

	local collides = 0
	local min = initialFraction
	local max = targetFraction
	for _ = 1, 32 do
		local mid = 0.5 * (min + max)
		resizeFunction(mid)
		lastIterationHadCollision = self._jointMaker:isColliding(includeInitiallyTouching)
		if lastIterationHadCollision then
			collides = collides + 1
			max = mid
		else
			min = mid
		end
	end

	-- Don't allow slightly resizing away from the last value (which would
	-- introduce floating point error but no useful changes)
	if math.abs(min - initialFraction) < threshold then
		lastIterationHadCollision = true
		min = initialFraction
	end

	-- Ensure we stop in a non-colliding state
	if lastIterationHadCollision then
		resizeFunction(min)
	end

	return min
end

function ExtrudeHandlesImplementation:_recordItemsToFixup(parts, models)
	self._fixupAttachments = {}
	self._fixupNontrivialAttachments = {}
	self._fixupOffsets = {}
	self._fixupScales = {}
	self._fixupPartPivot = {}
	self._fixupModelPivot = {}
	local pivotBasis = self._originalBoundingBoxCFrame:Inverse()
	for _, model in ipairs(models) do
		self._fixupModelPivot[model] = pivotBasis * model:GetPivot()
	end

	for _, part in ipairs(parts) do
		local inverseCFrame = part.CFrame:Inverse()
		local pivot = part.PivotOffset
		if pivot ~= EMPTY_CFRAME then
			self._fixupPartPivot[part] = pivot
		end
		for _, descendant in ipairs(part:GetDescendants()) do
			if descendant:IsA("Attachment") then
				if descendant.Parent ~= part then
					-- Note: We need this for bones, which may be under another
					-- bone rather than directly under the part.
					local cframeRelativeToPart = inverseCFrame * descendant.WorldCFrame
					local localPosition = cframeRelativeToPart.Position
					local localRotation = cframeRelativeToPart - localPosition
					table.insert(self._fixupNontrivialAttachments, {
						Attachment = descendant,
						RelativeTo = part,
						LocalRotation = localRotation, 
						LocalPosition = localPosition,
					})
				else
					self._fixupAttachments[descendant] = descendant.Position
				end
			elseif descendant:IsA("DataModelMesh") then
				self._fixupOffsets[descendant] = descendant.Offset
				if descendant.ClassName == "FileMesh" or
					(descendant:IsA("SpecialMesh") and descendant.MeshType == Enum.MeshType.FileMesh) then
					self._fixupScales[descendant] = descendant.Scale
				end
			end
		end
	end
end

function ExtrudeHandlesImplementation:_applyFixup(scaledBy, translatedBy)
	for attachment, position in pairs(self._fixupAttachments) do
		attachment.Position = position * scaledBy
	end

	-- Note: The forwards iteration is important here. Parents must have
	-- their CFrames updated first for things to work out as intended, as
	-- we're assigning WorldCFrame, which has a dependency on the CFrames
	-- of the ancestor attachments.
	for _, data in ipairs(self._fixupNontrivialAttachments) do
		data.Attachment.WorldCFrame =
			data.RelativeTo.CFrame * CFrame.new(data.LocalPosition * scaledBy) * data.LocalRotation
	end
	
	for offsetItem, offset in pairs(self._fixupOffsets) do
		offsetItem.Offset = offset * scaledBy
	end
	for scaleItem, scale in pairs(self._fixupScales) do
		scaleItem.Scale = scale * scaledBy
	end
	for part, localPivot in pairs(self._fixupPartPivot) do
		local position = localPivot.Position
		local rotation = localPivot - position
		part.PivotOffset = rotation + position * scaledBy
	end
	for model, localPivot in pairs(self._fixupModelPivot) do
		local position = localPivot.Position
		local rotation = localPivot - position
		model.WorldPivot = self._originalBoundingBoxCFrame * CFrame.new(translatedBy + position * scaledBy) * rotation
	end
end

return ExtrudeHandlesImplementation