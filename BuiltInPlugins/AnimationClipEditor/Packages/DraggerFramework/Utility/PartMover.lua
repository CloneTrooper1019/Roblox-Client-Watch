--[[
	Shared utility class which transforms parts efficiently as a group, and
	manages joining / unjoining them from the world.
]]
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local DraggerFramework = script.Parent.Parent
local getGeometry = require(DraggerFramework.Utility.getGeometry)
local JointPairs = require(DraggerFramework.Utility.JointPairs)
local JointUtil = require(DraggerFramework.Utility.JointUtil)

local getFFlagOnlyGetGeometryOnce = require(DraggerFramework.Flags.getFFlagOnlyGetGeometryOnce)

local DEFAULT_COLLISION_THRESHOLD = 0.001

-- Get all the instances the user has directly selected (actually part of the
-- selection)
local function getSelectedInstanceSet(selection)
	local selectedInstanceSet = {}
	for _, instance in pairs(selection) do
		selectedInstanceSet[instance] = true
	end
	return selectedInstanceSet
end

local PartMover = {}
PartMover.__index = PartMover

--[[
	Default value for IK dragging translation and rotation stiffness.
]]
local DRAG_CONSTRAINT_STIFFNESS = 0.85
local DRAG_CONSTRAINT_LESS_STIFFNESS = 0.40

function PartMover.new()
	local self = setmetatable({
		_partSet = {},
		_toUnanchor = {},
		_facesToHighlightSet = {},
		_nearbyGeometry = { --[[ [BasePart x]: (self:_getGeometry(x)) ]] },
	}, PartMover)
	self:_createMainPart()
	return self
end

--[[
	The part we're using to move stuff that needs to be ignored for raycasting.
]]
function PartMover:getIgnorePart()
	return self._mainPart
end

function PartMover:setDragged(parts, originalCFrameMap, breakJoints, customCenter, selection, allModels)
	-- Separate out the Workspace parts which will be passed to
	-- Workspace::ArePartsTouchingOthers for collision testing
	local workspaceParts = table.create(16)
	for _, part in ipairs(parts) do
		if part:IsDescendantOf(Workspace) then
			-- The part:GetRootPart() check should not be needed!
			-- This is a hack because parts under the workspace are supposed to
			-- always have a root part, but under some unknown extremely rare
			-- circumstances they do not.
			if part:GetRootPart() then
				table.insert(workspaceParts, part)
			else
				warn("Part `"..part:GetFullName().."` is missing a root! " ..
					"Please make a bug report explaining how you triggered this warning " ..
					"on the Developer Forum or https://www.roblox.com/support.")
			end
		end
	end
	self._workspaceParts = workspaceParts

	assert(not self._moving)
	self._moving = true
	self._originalCFrameMap = originalCFrameMap
	if #parts == 0 then
		self._parts = {}
		return
	end
	self:_initPartSet(parts)
	self._customCenter = customCenter or Vector3.new()
	self:_prepareJoints(parts, breakJoints)
	self._hasSetupGeometryTracking = false
	self:_setupBulkMove(parts, getSelectedInstanceSet(selection))

	local originalModelPivotMap = {}
	for _, model in ipairs(allModels) do
		originalModelPivotMap[model] = model:GetPivot()
	end
	self._originalModelPivotMap = originalModelPivotMap

	self._parts = parts
	self._hasMovementWelds = false
end

function PartMover:_setupBulkMove(parts, selectedInstanceSet)
	local movingRootSet = {}
	local originalCFrameMap = self._originalCFrameMap

	-- Directly selected instances need special handling, they must be moved
	-- with CFrame changes. If they are not, the properties widget will not
	-- show updates to their properties in real time, that is why there are
	-- two loops below: A first pass to handle all the directly selected
	-- instances, and a second pass to capture everything else.

	local moveWithCFrameChangeOriginalCFrameArray = {}
	local moveWithCFrameChangePartArray = {}
	local moveWithCFrameChangeNextIndex = 1
	for _, part in ipairs(parts) do
		if selectedInstanceSet[part] then
			-- Only need to care about parts which are their own root here.
			-- In order to move directly selected parts, at least one of the
			-- directly selected parts will usually become a root as the
			-- selection is dis-jointed from the surroundings at the start
			-- of the drag. The only edge-case this does not cover is the
			-- case where you select a model and part welded to the model,
			-- and the assembly root is in the model. This case is not
			-- possible to handle so don't worry about it.
			if (part:GetRootPart() or part) == part then
				-- We don't need to check whether we're already in the set,
				-- because the root == part check already implies that
				-- we're not as long as the parts list doesn't have
				-- duplicates (a condition which is enforced elsewhere).
				movingRootSet[part] = true

				moveWithCFrameChangePartArray[moveWithCFrameChangeNextIndex] = part
				moveWithCFrameChangeOriginalCFrameArray[moveWithCFrameChangeNextIndex] =
					originalCFrameMap[part]
				moveWithCFrameChangeNextIndex = moveWithCFrameChangeNextIndex + 1
			end
		end
	end

	local partsToBulkMoveArray = {}
	local originalCFramesArray = {}
	local nextIndexToInsertAt = 1
	for _, part in ipairs(parts) do
		local movementRoot = part:GetRootPart() or part
		if not movingRootSet[movementRoot] then
			movingRootSet[movementRoot] = true

			partsToBulkMoveArray[nextIndexToInsertAt] = movementRoot
			originalCFramesArray[nextIndexToInsertAt] = originalCFrameMap[movementRoot]
			nextIndexToInsertAt = nextIndexToInsertAt + 1
		end
	end

	-- Anchor all of the unanchored roots if we're dragging while simulation
	-- is happening, so that the parts don't move around as we're trying
	-- to drag them.
	if RunService:IsRunning() then
		for root, _ in pairs(movingRootSet) do
			if not root.Anchored then
				root.Anchored = true
				self._toUnanchor[root] = true
			end
		end
	end

	self._moveWithCFrameChangeParts = moveWithCFrameChangePartArray
	self._moveWithCFrameChangeOriginalCFrames = moveWithCFrameChangeOriginalCFrameArray
	self._moveWithCFrameChangeTargetCFrames = table.create(#moveWithCFrameChangePartArray)
	self._bulkMoveParts = partsToBulkMoveArray
	self._bulkMoveOriginalCFrames = originalCFramesArray
	self._bulkMoveTargetCFrames = table.create(#partsToBulkMoveArray)
end

function PartMover:_initPartSet(parts)
	self._partSet = {}
	for _, part in ipairs(parts) do
		self._partSet[part] = true
	end
end

--[[
	_getGeometry caches into nearbyGeometry, so here we reset that table
	and load the initial geometry of the parts to move into the cache.
]]
function PartMover:_setupGeometryTracking(parts)
	if getFFlagOnlyGetGeometryOnce() then
		-- Remove the parts argument with OnlyGetGeometryOnce flag
		assert(parts == nil)
		assert(not self._hasSetupGeometryTracking)
	end
	self._nearbyGeometry = {}
	self._rootPartSet = {}

	if getFFlagOnlyGetGeometryOnce() then
		for _, part in ipairs(self._workspaceParts) do
			-- If the part somehow got removed from the workspace (for instance,
			-- by a user plugin) since we added it to the _workspaceParts table,
			-- then it won't have a root part.
			local root = part:GetRootPart()
			if root then
				-- We have to track the roots separately, because some of the root parts
				-- of the dragged parts may not be in the set of dragged parts.
				self._rootPartSet[root] = true
			end
		end
	else
		for _, part in ipairs(parts) do
			-- We have to track the roots separately, because some of the root parts
			-- of the dragged parts may not be in the set of dragged parts.
			self._rootPartSet[part:GetRootPart()] = true
		end
	end
end

--[[
	Call once per move, setup geometry tracking.
]]
function PartMover:_ensureGeometryTrackingHasBeenSetup()
	if not self._hasSetupGeometryTracking then
		self:_setupGeometryTracking()
		self._hasSetupGeometryTracking = true
	end
end

--[[
	Create an auxiliary part to weld everything to in order to move everything
	as a single aggregate from the Lua side.
]]
function PartMover:_createMainPart()
	local part = Instance.new("Part")
	part.Name = "PartDragMover"
	part.Transparency = 1
	part.Archivable = false
	part.CanCollide = false

	-- 0 Density so that we don't effect the IK drag weighting
	part.CustomPhysicalProperties =
		PhysicalProperties.new(
			0, -- Density
			0.3, -- Friction
			0.5 -- Elasticity
		)

	self._mainPart = part
	self._originalMainPartCFrame = part.CFrame
end

function PartMover:_setupMainPart(customCenter)
	-- Part must be anchored in run mode, so that physics can't simulate it.
	-- However, the part must be UNanchored in normal mode, because IK dragging
	-- won't work if the part is anchored.
	self._mainPart.Anchored = RunService:IsRunning()
	self._originalMainPartCFrame = CFrame.new(customCenter)
	self._mainPart.CFrame = self._originalMainPartCFrame
	self._mainPart.Parent = Workspace.Terrain
	self._partSet[self._mainPart] = true
end

--[[
	Every moved part is joined together so that we can move the parts as
	a single solid body with only one property set from Lua.
	If breakJoints is true, break joints to outsiders before doing the drag
]]
function PartMover:_prepareJoints(parts, breakJoints)
	self._reenableWeldConstraints = {}
	self._alreadyConnectedToSets = {}
	for _, part in ipairs(parts) do
		self._alreadyConnectedToSets[part] = {}
		for _, joint in ipairs(part:GetJoints()) do
			if joint:IsA("JointInstance") then
				local other = JointUtil.getJointInstanceCounterpart(joint, part)
				if breakJoints then
					if not self._partSet[other] then
						-- We can't destroy these, otherwise Undo behavior
						-- won't be able to put them back in the workspace.
						joint.Parent = nil
					end
				else
					self._alreadyConnectedToSets[part][other] = true
				end
			elseif joint:IsA("Constraint") then
				-- Constraints don't effect non-IK movement, so
				-- we don't have to break or unparent them.

				-- However we do have to record the constraints between
				-- parts so that we know what joint pairs are redundant.
				local other = JointUtil.getConstraintCounterpart(joint, part)
				if other then
					-- The if is because some constraints like VectorForce
					-- will not have a counterpart.
					self._alreadyConnectedToSets[part][other] = true
				end
			elseif joint:IsA("WeldConstraint") then
				local other = JointUtil.getWeldConstraintCounterpart(joint, part)
				self._alreadyConnectedToSets[part][other] = true

				if breakJoints then
					-- Weld constraints to non-dragged parts need to be disabled,
					-- and then re-enabled after the move. Note: To show up in
					-- GetJoints, this weld must have been enabled.
					if not self._partSet[other] then
						joint.Enabled = false
						self._reenableWeldConstraints[joint] = true
					end
				end
			elseif joint:IsA("NoCollisionConstraint") then
				local other = JointUtil.getNoCollisionConstraintCounterpart(joint, part)
				self._alreadyConnectedToSets[part][other] = true
			else
				error("Unexpected Joint Type: " .. joint.ClassName)
			end
		end
	end
end

function PartMover:_installMovementWelds()
	if self._hasMovementWelds then
		return
	end

	self:_setupMainPart(self._customCenter)
	self._hasMovementWelds = true
	self._temporaryJoints = {}
	local mainPartCFrameInv = self._originalMainPartCFrame:Inverse()
	for _, part in ipairs(self._parts) do
		local moveJoint = Instance.new("Weld")
		moveJoint.Archivable = false
		moveJoint.Name = "Temp Movement Weld"
		moveJoint.Part0 = self._mainPart
		moveJoint.Part1 = part
		moveJoint.C0 = mainPartCFrameInv * part.CFrame
		moveJoint.Parent = self._mainPart
		table.insert(self._temporaryJoints, moveJoint)
	end
end

-- Find the candidate joints after transforming the dragged parts by `transform`
function PartMover:computeJointPairs(globalTransform)
	assert(self._moving)

	if getFFlagOnlyGetGeometryOnce() then
		self:_ensureGeometryTrackingHasBeenSetup()
	else
		if not self._hasSetupGeometryTracking then
			self:_setupGeometryTracking(self._workspaceParts)
		end
	end

	local jointPairs = JointPairs.new(self._parts, self._partSet, self._rootPartSet,
		globalTransform,
		self._alreadyConnectedToSets, function(part)
			-- Note, the part may not be in originalCFrameMap, in which case
			-- assumedCFrame = nil, which is the correct value for that case.
			local assumedCFrame = self._originalCFrameMap[part]
			return self:_getGeometry(part, assumedCFrame)
		end)

	if RunService:IsRunning() then
		if getFFlagOnlyGetGeometryOnce() then
			self:_flushNonDraggedGeometryCache()
		else
			self:_clearOtherGeometry()
		end
	end

	return jointPairs
end

function PartMover:_transformModelPivots(globalTransform)
	if self._originalModelPivotMap then
		for model, originalPivot in pairs(self._originalModelPivotMap) do
			model.WorldPivot = globalTransform * originalPivot
		end
	end
end

function PartMover:_transformToImpl(transform, mode)
	if self._bulkMoveParts then
		local targets = self._bulkMoveTargetCFrames
		local originals = self._bulkMoveOriginalCFrames
		for i = 1, #self._bulkMoveParts do
			targets[i] = transform * originals[i]
		end
		Workspace:BulkMoveTo(self._bulkMoveParts, targets, mode)
		targets = self._moveWithCFrameChangeTargetCFrames
		originals = self._moveWithCFrameChangeOriginalCFrames
		for i = 1, #self._moveWithCFrameChangeParts do
			targets[i] = transform * originals[i]
		end
		Workspace:BulkMoveTo(self._moveWithCFrameChangeParts, targets, Enum.BulkMoveMode.FireAllEvents)
	end
	self:_transformModelPivots(transform)
end

--[[
	The main function to move the parts geometrically.
]]
function PartMover:transformTo(transform)
	assert(self._moving)
	self._lastTransform = transform
	self:_transformToImpl(transform, Enum.BulkMoveMode.FireCFrameChanged)
end

--[[
	The main function to move the parts via inverse kinematics.
]]
function PartMover:transformToWithIk(transform, translateStiffness, rotateStiffness, collisionsMode)
	assert(self._moving)
	-- If we have no physical parts, then IK dragging is the same as
	-- geometric dragging. (We still may have free parts to move)
	if #self._parts == 0 then
		self:transformTo(transform)
		return transform
	end

	-- Make sure the movement welds exist, they are needed to do IK movement
	self:_installMovementWelds()

	local targetCFrame = transform * self._originalMainPartCFrame

	pcall(function()
		Workspace:IKMoveTo(
			self._mainPart, targetCFrame,
			translateStiffness, rotateStiffness,
			collisionsMode)
	end)
	local actualCFrame = self._mainPart.CFrame
	local actualGlobalTransform = actualCFrame * self._originalMainPartCFrame:Inverse()

	self:_transformModelPivots(actualGlobalTransform)

	-- We need to clear all non-dragged parts cached geometry, since we may
	-- have bumped into and moved other parts as part of the IK move.
	self:_flushNonDraggedGeometryCache()

	return actualGlobalTransform
end

function PartMover:moveToWithIk(transform, collisionsMode)
	local translateStiffness = DRAG_CONSTRAINT_STIFFNESS
	local rotateStiffness = DRAG_CONSTRAINT_LESS_STIFFNESS
	return self:transformToWithIk(transform, translateStiffness, rotateStiffness, collisionsMode)
end

function PartMover:rotateToWithIk(transform, collisionsMode)
	local translateStiffness = DRAG_CONSTRAINT_LESS_STIFFNESS
	local rotateStiffness = DRAG_CONSTRAINT_STIFFNESS
	return self:transformToWithIk(transform, translateStiffness, rotateStiffness, collisionsMode)
end


--[[
	Are any of the parts to move intersecting other parts not in the set of
	parts to move?
]]
function PartMover:isIntersectingOthers(overlapToIgnore)
	assert(self._moving)
	if getFFlagOnlyGetGeometryOnce() then
		-- Pcall because a user plugin may have removed some of the _workspaceParts
		-- from the workspace mid-move, and ArePartsTouchingOthers requires all the
		-- passed parts to be in a WorldRoot.
		local st, result = pcall(Workspace.ArePartsTouchingOthers, Workspace,
			self._workspaceParts, overlapToIgnore or DEFAULT_COLLISION_THRESHOLD)
		if st then
			return result
		else
			return true
		end
	else
		return Workspace:ArePartsTouchingOthers(self._workspaceParts,
			overlapToIgnore or DEFAULT_COLLISION_THRESHOLD)
	end
end

--[[
	Finish moving parts, and removing all of the temporary joints.
]]
function PartMover:commit()
	assert(self._moving)
	self._moving = false
	if self._mainPart then
		self._mainPart.Parent = nil
	end
	if self._reenableWeldConstraints then
		for weldConstraint, _ in pairs(self._reenableWeldConstraints) do
			weldConstraint.Enabled = true
		end
		self._reenableWeldConstraints = nil
	end
	self._facesToHighlightSet = {}
	if self._temporaryJoints then
		for _, joint in ipairs(self._temporaryJoints) do
			joint:Destroy()
		end
		self._temporaryJoints = {}
	end
	for part, _ in pairs(self._toUnanchor) do
		part.Anchored = false
	end
	self._toUnanchor = {}

	if self._bulkMoveParts then
		self._moveWithCFrameChangeParts = nil
		self._moveWithCFrameChangeOriginalCFrames = nil
		self._moveWithCFrameChangeTargetCFrames = nil
		self._bulkMoveParts = nil
		self._bulkMoveOriginalCFrames = nil
		self._bulkMoveTargetCFrames = nil
	end

	-- Note: We didn't do anything with the freeParts during commit. That's
	-- because there's nothing to do with them, they are not simulated in any
	-- way, so the changes we already made to their CFrames suffice.
end

local function augmentGeometry(geometry)
	-- Add additional precomputed fields to geometry
	-- Nothing to do for now. I needed something in here in the past and for
	-- optimizations we will probably want to precompute some things in here.
end

function PartMover:_getGeometry(part, assumedCFrame)
	local geometry = self._nearbyGeometry[part]
	if not geometry then
		geometry = getGeometry(part, Vector3.new(), assumedCFrame)
		self._nearbyGeometry[part] = geometry
		augmentGeometry(geometry)
	end
	return geometry
end

--[[
	Use this function to clear other part geometry after finishing a frame's
	worth of operation.

	In run mode, we can't keep the geometry of parts other than those we're
	moving cached between frames, because physics may move those parts. However
	we still want to keep them cached _within_ a frame, because multiple parts
	may need to check for joints vs a given part's geometry.
]]
if not getFFlagOnlyGetGeometryOnce() then
	function PartMover:_clearOtherGeometry()
		for part, _ in pairs(self._nearbyGeometry) do
			if not self._partSet[part] then
				self._nearbyGeometry[part] = nil
			end
		end
	end
end

function PartMover:_flushNonDraggedGeometryCache()
	for part, _ in pairs(self._nearbyGeometry) do
		if not self._partSet[part] then
			self._nearbyGeometry[part] = nil
		end
	end
end

return PartMover