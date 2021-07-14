local Workspace = game:GetService("Workspace")

-- Libraries
local DraggerFramework = script.Parent.Parent
local Plugin = DraggerFramework.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

-- Dragger Framework
local Colors = require(DraggerFramework.Utility.Colors)
local Math = require(DraggerFramework.Utility.Math)
local StandaloneSelectionBox = require(DraggerFramework.Components.StandaloneSelectionBox)
local roundRotation = require(DraggerFramework.Utility.roundRotation)
local snapRotationToPrimaryDirection = require(DraggerFramework.Utility.snapRotationToPrimaryDirection)

local RotateHandleView = require(DraggerFramework.Components.RotateHandleView)
local SummonHandlesNote = require(DraggerFramework.Components.SummonHandlesNote)
local SummonHandlesHider = require(DraggerFramework.Components.SummonHandlesHider)
local DraggedPivot = require(DraggerFramework.Components.DraggedPivot)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)

local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

-- The minimum rotate increment to display snapping increments for (below this
-- increment there are so many points that they become visual noise)
local MIN_ROTATE_INCREMENT = 5.0

local RIGHT_ANGLE = math.pi / 2
local RIGHT_ANGLE_EXACT_THRESHOLD = 0.001

local RotateHandles = {}
RotateHandles.__index = RotateHandles

--[[
	Axis of rotation is the CFrame right vector.
	RadiusOffset slightly bumps the arc radii so that we can control which one
	shows up on top where they intersect.
]]
local RotateHandleDefinitions = {
	XAxis = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)),
		Color = Colors.X_AXIS,
		RadiusOffset = 0.00,
	},
	YAxis = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0)),
		Color = Colors.Y_AXIS,
		RadiusOffset = 0.01,
	},
	ZAxis = {
		Offset = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, 1), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0)),
		Color = Colors.Z_AXIS,
		RadiusOffset = 0.02,
	},
}

local function isRightAngle(angleDelta)
	local snappedTo90 = math.floor((angleDelta / RIGHT_ANGLE) + 0.5) * RIGHT_ANGLE
	return math.abs(snappedTo90 - angleDelta) < RIGHT_ANGLE_EXACT_THRESHOLD
end

local function getRotationTransform(mainCFrame, axisVector, delta, rotateIncrement)
	local localAxis = mainCFrame:VectorToObjectSpace(axisVector)
	local rotationCFrame = CFrame.fromAxisAngle(localAxis, delta)

	-- Special case rotations in 90 degree increments as a permutation of
	-- the identity matrix rather than numerically calculating an axis
	-- rotation which would introduce floating point error.
	if rotateIncrement > 0 and isRightAngle(delta) then
		-- Since we know that this is already almost a right angle rotation
		-- thanks to the isRightAngle check, we can find the pure
		-- permutation rotation matrix simply by rounding the rotation
		-- matrix elements to the nearest integer.
		rotationCFrame = roundRotation(rotationCFrame)
	end

	-- Convert the rotation to a global space transformation
	return mainCFrame * rotationCFrame * mainCFrame:Inverse()
end

--[[
	Find the angle around the rotation axis where the mouse ray intersects the
	plane perpendicular to the rotation axis.
]]
local function rotationAngleFromRay(cframe, unitRay)
	local t = Math.intersectRayPlane(unitRay.Origin, unitRay.Direction, cframe.Position, cframe.RightVector)
	if t >= 0 then
		local mouseWorld = unitRay.Origin + unitRay.Direction * t
		local direction = (mouseWorld - cframe.Position).Unit
		local rx = cframe.LookVector:Dot(direction)
		local ry = cframe.UpVector:Dot(direction)

		-- Remap into [0, 2pi] for better snapping behavior with not
		-- evenly divisible snapping angles.
		local theta = math.atan2(ry, rx)
		if theta < 0 then
			return 2 * math.pi + theta
		else
			return theta
		end
	end
	return nil
end

local function snapToRotateIncrementIfNeeded(angle, rotateIncrement)
	if rotateIncrement > 0 then
		local angleIncrement = math.rad(rotateIncrement)
		local snappedAngle = math.floor(angle / angleIncrement + 0.5) * angleIncrement
		local deltaFromCompleteRotation = math.abs(angle - math.pi * 2)
		local deltaFromSnapPoint = math.abs(angle - snappedAngle)
		if deltaFromCompleteRotation < deltaFromSnapPoint then
			-- For rotate increments which don't evenly divide the
			-- circle, there won't be a snap point at 360 degrees, so
			-- this if statement manually adds a special case for that
			-- additional snap point.
			return 0
		else
			return snappedAngle
		end
	else
		return angle
	end
end

function RotateHandles.new(draggerContext, props, implementation)
	local self = {}
	self._draggerContext = draggerContext
	self._handles = {}
	self._props = props or {
		Summonable = true,
	}
	self._implementation = implementation
	self._tabKeyDown = false
	return setmetatable(self, RotateHandles)
end

-- Summon handles to the current mouse hover location
function RotateHandles:_summonHandles()
	if not self._props.Summonable then
		return false
	end

	local mouseRay = self._draggerContext:getMouseRay()
	local hitSelectable, hitItem, distance = self._schema.getMouseTarget(self._draggerContext, mouseRay, {})
	if hitItem then
		local hitPoint = mouseRay.Origin + mouseRay.Direction.Unit * distance
		self._summonBasisOffset = CFrame.new(self._boundingBox.CFrame:PointToObjectSpace(hitPoint))

		if self._implementation.findSummonSnap then
			local snappedHitCFrame, isOnSurface = self._implementation:findSummonSnap(hitPoint, hitItem)
			if snappedHitCFrame then
				local snappedBasisOffset = self._boundingBox.CFrame:ToObjectSpace(snappedHitCFrame)
				local toOldBasisOffset = snappedBasisOffset:Inverse() * self._summonBasisOffset

				self._summonBasisOffset = snappedBasisOffset * snapRotationToPrimaryDirection(toOldBasisOffset)
				self._summonWasSnapped = true
				self._summonWasSnappedToSurface = isOnSurface
			end
		end
	end
end

function RotateHandles:_endSummon()
	if self._summonBasisOffset then
		self._summonBasisOffset = nil
		self._summonWasSnapped = false
		self._summonWasSnappedToSurface = false
	end
end

function RotateHandles:_getBasisOffset()
	return self._summonBasisOffset or self._basisOffset
end

function RotateHandles:update(draggerToolModel, selectionInfo)
	if not self._draggingHandleId then
		if getFFlagSummonPivot() and not self._tabKeyDown then
			self:_endSummon()
		end

		local cframe, offset, size = selectionInfo:getBoundingBox()
		self._boundingBox = {
			Size = size,
			CFrame = cframe * CFrame.new(offset),
		}
		self._basisOffset = CFrame.new(-offset)
		self._selectionInfo = selectionInfo
		self._selectionWrapper = draggerToolModel:getSelectionWrapper()
		self._schema = draggerToolModel:getSchema()
		if getEngineFeatureModelPivotVisual() then
			if getFFlagSummonPivot() then
				self._scale = self._draggerContext:getHandleScale((self._boundingBox.CFrame * self:_getBasisOffset()).Position)
			else
				self._scale = self._draggerContext:getHandleScale(cframe.Position)
			end
		else
			self._scale = self._draggerContext:getHandleScale(self._boundingBox.CFrame.Position)
		end
	end
	self:_updateHandles()
end

function RotateHandles:shouldBiasTowardsObjects()
	return false
end

function RotateHandles:hitTest(mouseRay, ignoreExtraThreshold)
	local closestHandleId, closestHandleDistance = nil, math.huge
	for handleId, handleProps in pairs(self._handles) do
		local distance = RotateHandleView.hitTest(handleProps, mouseRay)
		if distance and distance < closestHandleDistance then
			closestHandleDistance = distance
			closestHandleId = handleId
		end
	end

	local alwaysOnTop = true
	return closestHandleId, closestHandleDistance, alwaysOnTop
end

function RotateHandles:render(hoveredHandleId)
	local children = {}

	local increment = self._draggerContext:getRotateIncrement()
	local tickAngle
	if increment >= MIN_ROTATE_INCREMENT then
		tickAngle = math.rad(increment)
	end

	if self._draggingHandleId and self._handles[self._draggingHandleId] then
		local handleProps = self._handles[self._draggingHandleId]
		children[self._draggingHandleId] = Roact.createElement(RotateHandleView, {
			HandleCFrame = handleProps.HandleCFrame,
			Color = handleProps.Color,
			StartAngle = self._startAngle - self._draggingLastGoodDelta,
			EndAngle = self._startAngle,
			Scale = self._scale,
			Hovered = false,
			RadiusOffset = handleProps.RadiusOffset,
			TickAngle = tickAngle,
		})

		-- Show the other handles, but thinner
		for handleId, otherHandleProps in pairs(self._handles) do
			if handleId ~= self._draggingHandleId then
				local offset = RotateHandleDefinitions[handleId].Offset
				children[handleId] = Roact.createElement(RotateHandleView, {
					HandleCFrame = self._boundingBox.CFrame * offset,
					Color = Colors.makeDimmed(otherHandleProps.Color),
					Scale = self._scale,
					Thin = true,
					RadiusOffset = handleProps.RadiusOffset,
				})
			end
		end

		if getFFlagSummonPivot() then
			children.ImplementationRendered =
				self._implementation:render(self._lastGlobalTransformForRender)
		else
			children.ImplementationRendered =
				self._implementation:render(self._boundingBox.CFrame * self._basisOffset)
		end
	else
		for handleId, handleProps in pairs(self._handles) do
			local color = handleProps.Color
			local hovered = (handleId == hoveredHandleId)
			local tickAngleToUse
			if hovered then
				tickAngleToUse = tickAngle
			else
				color = Colors.makeDimmed(color)
			end
			children[handleId] = Roact.createElement(RotateHandleView, {
				HandleCFrame = handleProps.HandleCFrame,
				Color = color,
				Scale = self._scale,
				Hovered = hovered,
				RadiusOffset = handleProps.RadiusOffset,
				TickAngle = tickAngleToUse,
			})
		end
	end

	if self._props.ShowBoundingBox and #self._selectionWrapper:get() > 1 then
		children.SelectionBoundingBox = Roact.createElement(StandaloneSelectionBox, {
			CFrame = self._boundingBox.CFrame,
			Size = self._boundingBox.Size,
			Color = self._draggerContext:getSelectionBoxColor(),
			LineThickness = self._draggerContext:getHoverLineThickness(),
			Container = self._draggerContext:getGuiParent(),
		})
	end

	if getFFlagSummonPivot() and self._props.Summonable then
		if self._summonBasisOffset then
			if self._summonWasSnapped then
				children.SummonSnap = Roact.createElement("BoxHandleAdornment", {
					Adornee = Workspace.Terrain,
					Color3 = self._draggerContext:getGeometrySnapColor(),
					CFrame = self._boundingBox.CFrame * self._summonBasisOffset,
					Size = Vector3.new(0.5, 0.5, 0.5) * self._scale,
					AlwaysOnTop = not self._summonWasSnappedToSurface,
					Transparency = self._summonWasSnappedToSurface and 0.0 or 0.5,
					ZIndex = 0,
				})
			else
				children.SummonedPivot = Roact.createElement(DraggedPivot, {
					DraggerContext = self._draggerContext,
					CFrame = self._boundingBox.CFrame * self:_getBasisOffset(),
					IsActive = self._draggerContext:shouldShowActiveInstanceHighlight() and (#self._selectionWrapper:get() == 1),
				})
			end
		end

		if not self._draggingHandleId then
			-- Show / hide the summon handles note
			if self._summonBasisOffset then
				children.SummonHandlesHider = Roact.createElement(SummonHandlesHider, {
					DraggerContext = self._draggerContext,
				})
			elseif not SummonHandlesHider.hasSeenEnough(self._draggerContext) then
				local worldPosition = (self._boundingBox.CFrame * self._basisOffset).Position
				local screenPosition, inView = self._draggerContext:worldToViewportPoint(worldPosition)
				if screenPosition.Z > 0 then
					children.SummonHandlesNote = Roact.createElement(SummonHandlesNote, {
						Position = Vector2.new(screenPosition.X, screenPosition.Y),
						InView = inView,
						DraggerContext = self._draggerContext,
					})
				end
			end
		end
	end

	return Roact.createElement("Folder", {}, children)
end

function RotateHandles:mouseDown(mouseRay, handleId)
	-- Attempted to re-drag a handle which no longer exists
	-- (happens if the selection changes in the middle of the drag in a way
	-- which causes the previously dragged handle to no longer exist)
	if not self._handles[handleId] then
		return
	end

	-- Check if we can find a starting angle
	local handleCFrame
	if getEngineFeatureModelPivotVisual() then
		handleCFrame = self._handles[handleId].HandleCFrame
	else
		local offset = RotateHandleDefinitions[handleId].Offset
		handleCFrame = self._boundingBox.CFrame * offset
	end
	local angle = rotationAngleFromRay(handleCFrame, mouseRay.Unit)
	if not angle then
		return
	end

	-- We can start a drag as a result of this mouse down
	self._draggingHandleId = handleId
	self._handleCFrame = handleCFrame
	self._lastGlobalTransformForRender = CFrame.new()
	self._draggingLastGoodDelta = 0
	self._originalBoundingBoxCFrame = self._boundingBox.CFrame
	self._startAngle = snapToRotateIncrementIfNeeded(
		angle, self._draggerContext:getRotateIncrement())

	self._implementation:beginDrag(self._selectionWrapper:get(), self._selectionInfo)
end

function RotateHandles:mouseDrag(mouseRay)
	-- We never started this drag in the first place
	if not self._handles[self._draggingHandleId] then
		return
	end

	local angle = rotationAngleFromRay(self._handleCFrame, mouseRay.Unit)
	if not angle then
		return
	end
	local snappedAngle =
		snapToRotateIncrementIfNeeded(angle, self._draggerContext:getRotateIncrement())

	local snappedDelta = snappedAngle - self._startAngle
	local candidateGlobalTransform = getRotationTransform(
		getEngineFeatureModelPivotVisual() and self._handleCFrame or self._originalBoundingBoxCFrame,
		self._handleCFrame.RightVector,
		snappedDelta,
		self._draggerContext:getRotateIncrement())

	local appliedGlobalTransform =
		self._implementation:updateDrag(candidateGlobalTransform)

	-- Adjust the bounding box
	self._boundingBox.CFrame = appliedGlobalTransform * self._originalBoundingBoxCFrame
	self._lastGlobalTransformForRender = appliedGlobalTransform

	-- Derive the applied rotation angle (we need to display this in the
	-- user interface)
	local rotatedAxis = appliedGlobalTransform:VectorToObjectSpace(self._handleCFrame.LookVector)
	local ry = self._handleCFrame.UpVector:Dot(rotatedAxis)
	local rx = self._handleCFrame.LookVector:Dot(rotatedAxis)
	self._draggingLastGoodDelta = -math.atan2(ry, rx)
end

function RotateHandles:mouseUp(mouseRay)
	-- We never started this drag in the first place
	if not self._draggingHandleId then
		return
	end
	if getFFlagSummonPivot() and not self._tabKeyDown then
		self:_endSummon()
	end

	self._draggingHandleId = nil
	local newSelectionInfoHint = self._implementation:endDrag()
	self._schema.addUndoWaypoint(self._draggerContext, "Axis Rotate Selection")
	return newSelectionInfoHint
end

function RotateHandles:_updateHandles()
	if self._selectionInfo:isEmpty() then
		self._handles = {}
	else
		for handleId, handleDefinition in pairs(RotateHandleDefinitions) do
			self._handles[handleId] = {
				HandleCFrame = getEngineFeatureModelPivotVisual() and
					(self._boundingBox.CFrame * self:_getBasisOffset() * handleDefinition.Offset) or
					(self._boundingBox.CFrame * handleDefinition.Offset),
				Color = handleDefinition.Color,
				RadiusOffset = handleDefinition.RadiusOffset,
				Scale = self._scale,
			}
		end
	end
end

if getEngineFeatureModelPivotVisual() and getFFlagSummonPivot() then
	function RotateHandles:keyDown(keyCode)
		if keyCode == Enum.KeyCode.Tab then
			self._tabKeyDown = true
			if not self._draggingHandleId then
				self:_summonHandles()
				return true
			end
		end
		return false
	end

	function RotateHandles:keyUp(keyCode)
		if keyCode == Enum.KeyCode.Tab then
			self._tabKeyDown = false
			if not self._draggingHandleId then
				self:_endSummon()
				return true
			end
		end
		return false
	end
end

return RotateHandles
