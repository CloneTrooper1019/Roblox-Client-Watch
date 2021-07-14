local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local Math = require(DraggerFramework.Utility.Math)
local getGeometry = require(DraggerFramework.Utility.getGeometry)
local roundRotation = require(DraggerFramework.Utility.roundRotation)
local snapRotationToPrimaryDirection = require(DraggerFramework.Utility.snapRotationToPrimaryDirection)

local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local PrimaryDirections = {
	Vector3.new(1, 0, 0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, -1, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 0, -1)
}

local DragTargetType = {
	Terrain = "Terrain",
	Polygon = "Polygon",
	Round = "Round",
	Nothing = "Nothing",
}

--[[
	If true, then "Rotate" will mean:
		Rotate around whatever axis of the drag target is closest to the
		camera's current up direction.
	If false, then "Rotate" always mean:
		Rotate around the normal of the surface we're dragging onto.
]]
local ROTATE_DEPENDS_ON_CAMERA = false

local DragHelper = {}

local VOXEL_RESOLUTION = 4
local function roundToTerrainGrid(value)
	return VOXEL_RESOLUTION * math.floor(value / VOXEL_RESOLUTION + 0.5)
end

local function findClosestBasis(normal)
	local mostPerpendicularNormal1
	local smallestDot = math.huge
	for _, primaryDirection in ipairs(PrimaryDirections) do
		local dot = math.abs(primaryDirection:Dot(normal))
		if dot < smallestDot then
			smallestDot = dot
			mostPerpendicularNormal1 = primaryDirection
		end
	end

	local mostPerpendicularNormal2 = mostPerpendicularNormal1:Cross(normal).Unit
	local closestNormal = -mostPerpendicularNormal1:Cross(mostPerpendicularNormal2)

	return closestNormal, mostPerpendicularNormal1, mostPerpendicularNormal2
end

-- Remove with FFlag::SummonPivot
local function largestComponent(vector)
	return math.max(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

-- Remove with FFlag::SummonPivot
function DragHelper.snapVectorToPrimaryDirection(direction)
	local largestDot = -math.huge
	local closestDirection
	for _, target in ipairs(PrimaryDirections) do
		local dot = direction:Dot(target)
		if dot > largestDot then
			largestDot = dot
			closestDirection = target
		end
	end
	return closestDirection
end

-- Remove with FFlag::SummonPivot
function DragHelper.snapRotationToPrimaryDirection(cframe)
	assert(not getFFlagSummonPivot())
	local right = cframe.RightVector
	local top = cframe.UpVector
	local front = -cframe.LookVector
	local largestRight = largestComponent(right)
	local largestTop = largestComponent(top)
	local largestFront = largestComponent(front)
	if largestRight > largestTop and largestRight > largestFront then
		-- Most aligned axis is X, the right, preserve that
		right = DragHelper.snapVectorToPrimaryDirection(right)
		if largestTop > largestFront then
			top = DragHelper.snapVectorToPrimaryDirection(top)
		else
			local front = DragHelper.snapVectorToPrimaryDirection(front)
			top = front:Cross(right).Unit
		end
	elseif largestTop > largestFront then
		-- Most aligned axis is Y, the top, preserve that
		top = DragHelper.snapVectorToPrimaryDirection(top)
		if largestRight > largestFront then
			right = DragHelper.snapVectorToPrimaryDirection(right)
		else
			local front = DragHelper.snapVectorToPrimaryDirection(front)
			right = top:Cross(front).Unit
		end
	else
		-- Most aligned axis is Z, the front, preserve that
		local front = DragHelper.snapVectorToPrimaryDirection(front)
		if largestRight > largestTop then
			right = DragHelper.snapVectorToPrimaryDirection(right)
			top = front:Cross(right).Unit
		else
			top = DragHelper.snapVectorToPrimaryDirection(top)
			right = top:Cross(front).Unit
		end
	end
	return CFrame.fromMatrix(Vector3.new(), right, top)
end

function DragHelper.getSizeInSpace(sizeInGlobalSpace, localSpace)
	local _, _, _,
		t00, t01, t02,
		t10, t11, t12,
		t20, t21, t22 = localSpace:GetComponents()
	local sx, sy, sz = sizeInGlobalSpace.X, sizeInGlobalSpace.Y, sizeInGlobalSpace.Z
	local w = (math.abs(sx * t00) + math.abs(sy * t01) + math.abs(sz * t02))
	local h = (math.abs(sx * t10) + math.abs(sy * t11) + math.abs(sz * t12))
	local d = (math.abs(sx * t20) + math.abs(sy * t21) + math.abs(sz * t22))
	return Vector3.new(w, h, d)
end

function DragHelper.getClosestFace(part, mouseWorld)
	local geom = getGeometry(part, mouseWorld)
	local closestFace
	local closestDist = math.huge
	for _, face in ipairs(geom.faces) do
		local dist = math.abs((mouseWorld - face.point):Dot(face.normal))
		if dist < closestDist then
			closestFace = face
			closestDist = dist
		end
	end
	return closestFace, geom
end

function DragHelper.getPartAndSurface(mouseRay)
	local part, mouseWorld = Workspace:FindPartOnRay(mouseRay)
	
	local closestFace, _
	if part then
		if part:IsA("Terrain") then
			-- Terrain doesn't have Primary Axis based surfaces to return
			return part, nil
		end

		closestFace, _ = DragHelper.getClosestFace(part, mouseWorld)
	end

	if closestFace then
		return part, closestFace.surface
	else
		return part, nil
	end
end

function DragHelper.getSurfaceMatrix(mouseRay, selection, lastSurfaceMatrix)
	local part, mouseWorld, normal = Workspace:FindPartOnRayWithIgnoreList(mouseRay, selection)
	if part and part:IsA("Terrain") then
		-- First, find the closest aligned global axis normal, and the two other
		-- axes mutually orthogonal to it.
		local closestNormal, mostPerpendicularNormal1, mostPerpendicularNormal2
			= findClosestBasis(normal)

		-- Now we want to grid-align mouseWorld by snapping it to the
		-- grid size of the terrain on the non-normal axes.
		local alongNormal1 = mouseWorld:Dot(mostPerpendicularNormal1)
		local alongNormal2 = mouseWorld:Dot(mostPerpendicularNormal2)
		local snappedMouseWorldBase =
			mostPerpendicularNormal1 * roundToTerrainGrid(alongNormal1) +
			mostPerpendicularNormal2 * roundToTerrainGrid(alongNormal2)

		-- Since we grid-aligned the position on two of the axis, we have to
		-- bring the position back into the surface plane on the other axis.
		-- Do that by solving the following equation:
		-- (snappedMouseWorldBase + closestNormal * adjustmentIntoPlane):Dot(normal) = mouseWorld:Dot(normal)
		local adjustmentIntoPlane =
			(mouseWorld:Dot(normal) - snappedMouseWorldBase:Dot(normal)) / closestNormal:Dot(normal)
		local snappedMouseWorld = snappedMouseWorldBase + closestNormal * adjustmentIntoPlane

		return CFrame.fromMatrix(snappedMouseWorld,
			normal:Cross(mostPerpendicularNormal1).Unit, normal),
			mouseWorld, DragTargetType.Terrain
	elseif part then
		-- Find the normal and secondary axis (the direction the studs / UV
		-- coords are oriented in) of the surface that we're dragging onto.
		-- Also find the closest "basis" point on the face to the mouse,
		local closestFace, geom = DragHelper.getClosestFace(part, mouseWorld)

		local normal = closestFace.normal
		local secondary;
		local closestEdgeDist = math.huge
		for _, edge in ipairs(geom.edges) do
			if (edge.a - closestFace.point):Dot(normal) < 0.001 and
				(edge.b - closestFace.point):Dot(normal) < 0.001
			then
				-- Both ends of the edge are part of the selected face,
				-- consider it
				local distAlongEdge = (mouseWorld - edge.a):Dot(edge.direction)
				local pointOnEdge = edge.a + edge.direction * distAlongEdge
				local distToEdge = (mouseWorld - pointOnEdge).Magnitude
				if distToEdge < closestEdgeDist then
					closestEdgeDist = distToEdge
					secondary = edge.direction
				end
			end
		end
		local targetBasisPoint
		local closestBasisDist = math.huge
		for _, vert in ipairs(closestFace.vertices) do
			local dist = (vert - mouseWorld).Magnitude
			if dist < closestBasisDist then
				closestBasisDist = dist
				targetBasisPoint = vert
			end
		end

		local dragTargetType = DragTargetType.Polygon

		-- TODO: Deal with round things better (this is the case that gets hit
		-- with round things like cylinders and spheres)
		if not secondary then
			dragTargetType = DragTargetType.Round
			secondary = normal:Cross(Vector3.new(1, 1, 1)).Unit
		end
		if not targetBasisPoint then
			targetBasisPoint = mouseWorld
		end

		-- Find the total transform from the target point on the dragged to
		-- surface to our original CFrame
		return CFrame.fromMatrix(targetBasisPoint, -secondary:Cross(normal), normal), mouseWorld, dragTargetType
	elseif lastSurfaceMatrix then
		-- Use the last target mat, and the intersection of the mouse mouseRay with
		-- that plane that target mat defined as the drag point.
		local t = Math.intersectRayPlane(
			mouseRay.Origin, mouseRay.Direction,
			lastSurfaceMatrix.Position, lastSurfaceMatrix.UpVector)
		mouseWorld = mouseRay.Origin + mouseRay.Direction * t
		return lastSurfaceMatrix, mouseWorld, DragTargetType.Nothing
	else
		-- No previous target or current target, can't drag
		return nil
	end
end

--[[
	Update the tiltRotate by rotating 90 degrees around an axis. Axis is the
	axis in camera space over which the rotation should happen.
]]
function DragHelper.updateTiltRotate(cameraCFrame, mouseRay, selection, mainCFrame, lastTargetMat, tiltRotate, axis,
	alignRotation)
	-- Find targetMatrix and dragInTargetSpace in the same way as
	-- in DragHelper.getDragTarget, see that function for further explanation.
	local targetMatrix, _, dragTargetType =
		DragHelper.getSurfaceMatrix(mouseRay, selection, lastTargetMat)
	if not targetMatrix then
		return tiltRotate
	end
	local dragInTargetSpace = targetMatrix:Inverse() * mainCFrame
	if alignRotation then
		if getFFlagSummonPivot() then
			dragInTargetSpace = snapRotationToPrimaryDirection(dragInTargetSpace)
		else
			dragInTargetSpace = DragHelper.snapRotationToPrimaryDirection(dragInTargetSpace)
		end
	else
		dragInTargetSpace = dragInTargetSpace - dragInTargetSpace.Position
	end

	-- Current global rotation when dragging is given by:
	--   (targetMatrix * dragInTargetSpace * tiltRotate)
	--
	-- So we need to find the local axis of:
	--   (targetMatrix * dragInTargetSpace)
	--
	-- Which is the closest to Camera.RightVector. Then we can construct
	-- the additional `rotation` to add to tiltRotate around that axis:
	--   (targetMatrix * dragInTargetSpace * (rotation * tiltRotate))
	local baseMatrix = targetMatrix * dragInTargetSpace
	local targetDirection
	if not ROTATE_DEPENDS_ON_CAMERA and axis == Vector3.new(0, 1, 0) then
		-- This will end up rotating around the normal of the target surface
		targetDirection = targetMatrix.UpVector
	else
		targetDirection = cameraCFrame:VectorToWorldSpace(axis)
	end

	-- Greater dot product = smaller angle, so the closest direction is
	-- the one with the greatest dot product.
	local closestAxis
	local closestDelta = -math.huge
	for _, direction in ipairs(PrimaryDirections) do
		local delta = baseMatrix:VectorToWorldSpace(direction):Dot(targetDirection)
		if delta > closestDelta then
			closestAxis = direction
			closestDelta = delta
		end
	end

	-- If we somehow had NaNs in our CFrame then closestAxis may still be nil
	closestAxis = closestAxis or Vector3.new(0, 1, 0)

	-- Could be written without the need for rounding by permuting the
	-- components of closestAxis, but this is more understandable.
	local rotation = roundRotation(CFrame.fromAxisAngle(closestAxis, math.pi / 2))
	return rotation * tiltRotate, dragTargetType
end

function DragHelper.getDragTarget(mouseRay, snapFunction, dragInMainSpace, selection, mainCFrame, basisPoint,
	boundingBoxSize, boundingBoxOffset, tiltRotate, lastTargetMat, alignRotation)
	if not dragInMainSpace then
		return
	end

	local targetMatrix, mouseWorld, dragTargetType =
		DragHelper.getSurfaceMatrix(mouseRay, selection, lastTargetMat)
	if not targetMatrix then
		return
	end

	local dragInTargetSpace = targetMatrix:Inverse() * mainCFrame
	if alignRotation then
		-- Now we want to "snap" the rotation of this transformation to 90 degree
		-- increments, such that the dragInTargetSpace is only some combination of
		-- the primary direction vectors.
		if getFFlagSummonPivot() then
			dragInTargetSpace = snapRotationToPrimaryDirection(dragInTargetSpace)
		else
			dragInTargetSpace = DragHelper.snapRotationToPrimaryDirection(dragInTargetSpace)
		end
	else
		-- Just reduce dragInTargetSpace to a rotation
		dragInTargetSpace = dragInTargetSpace - dragInTargetSpace.Position
	end

	-- Now we want to "snap" the basisPoint to be on-Grid in the main space
	-- the basisPoint is already in the main space, so we can just snap it to
	-- grid and see what offset it moved by. We will need to use a bounding box
	-- modified by that offset for the purposes of bumping, and also shift the
	-- parts by that much when we finally apply them. That is equivalent to
	-- applying the offset as a final factor in the transform this function
	-- returns.
	local offsetX = snapFunction(basisPoint.X) - basisPoint.X
	local offsetY = snapFunction(basisPoint.Y) - basisPoint.Y
	local offsetZ = snapFunction(basisPoint.Z) - basisPoint.Z

	local contentOffset = Vector3.new(offsetX, offsetY, offsetZ)
	local contentOffsetCF = CFrame.new(contentOffset)
	local snappedBoundingBoxOffset = boundingBoxOffset + contentOffset

	-- Compute the size in the space we're dragging into. If alignRotation
	-- is enabled, it could just be computed as a permutation of the size
	-- components. However, when it is an arbitrary rotational offset thanks
	-- to alignRotation being disabled, a larger computation is needed.
	local sizeInTargetSpace = DragHelper.getSizeInSpace(boundingBoxSize, dragInTargetSpace * tiltRotate)

	-- Figure out how much we have to "bump up" the selection to have its
	-- bounding box sit on top of the plane we're dragging onto.
	local offsetInTargetSpace = (dragInTargetSpace * tiltRotate):VectorToWorldSpace(snappedBoundingBoxOffset)
	local normalBumpNeeded = (0.5 * sizeInTargetSpace.Y) - offsetInTargetSpace.Y
	local normalBumpCF = CFrame.new(0, normalBumpNeeded, 0)

	-- Now we have to figure out the offset of the point we started the drag
	-- with from the mainCFrame, and apply that same offset from the point we
	-- dragged to on the new plane, to get a total offset which we should apply
	-- the increment snapping to in the target space.
	local mouseInMainSpace = dragInMainSpace
	local mouseInMainSpaceCF = CFrame.new(mouseInMainSpace)

	-- New mouse position is defined by:
	-- targetMatrix * snapAdjust * normalBump * dragInTargetSpace * tiltRotate * mouseInMainSpace * contentOffset =
	-- mouseWorld
	-- So we want to isolate snapAdjust to snap it's X and Z components
	local mouseWorldCF = (targetMatrix - targetMatrix.Position) * dragInTargetSpace * tiltRotate + mouseWorld
	local snapAdjust =
		targetMatrix:Inverse() *
		mouseWorldCF *
		(normalBumpCF * dragInTargetSpace * tiltRotate * mouseInMainSpaceCF * contentOffsetCF):inverse()

	-- Now that the snapping space is isolated we can apply the snap
	local snapAdjustCF = CFrame.new(snapFunction(snapAdjust.X), 0, snapFunction(snapAdjust.Z))

	-- Get the final CFrame to move the parts to.
	local rotatedBase =
		targetMatrix * snapAdjustCF * normalBumpCF *
		dragInTargetSpace * tiltRotate * contentOffsetCF

	-- Note: Snap point is the visual point that was snapped-to in world space
	-- if we want to display that at some point.
	local snapPoint = (targetMatrix * snapAdjustCF).Position

	return {
		mainCFrame = rotatedBase,
		snapPoint = snapPoint,
		targetMatrix = targetMatrix,
		dragTargetType = dragTargetType,
	}
end

-- All values should be in world coordinates
function DragHelper.getCameraPlaneDragTarget(mouseRay, cameraLookVector, clickPoint)
	if not clickPoint then
		return nil
	end

	local unitMouseRay = mouseRay.Unit
	local cameraPlaneNormal = -1 * cameraLookVector.Unit

	local t = Math.intersectRayPlane(unitMouseRay.Origin, unitMouseRay.Direction, clickPoint, cameraPlaneNormal)

	if t >= 0 then
		local targetPosition = unitMouseRay.Origin + (t * unitMouseRay.Direction)
		local positionDelta = targetPosition - clickPoint
		return {
			mainCFrame = CFrame.new(positionDelta),
			snapPoint = nil, -- not applicable to in-camera plane drag
			targetMatrix = nil, -- not applicable to in-camera plane drag
			dragTargetType = DragTargetType.Nothing,
		}
	end

	return nil
end

return DragHelper
