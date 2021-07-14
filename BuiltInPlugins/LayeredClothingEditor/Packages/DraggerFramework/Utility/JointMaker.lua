
local RunService = game:GetService("RunService")

local DraggerFramework = script.Parent.Parent
local getGeometry = require(DraggerFramework.Utility.getGeometry)
local JointPairs = require(DraggerFramework.Utility.JointPairs)
local JointUtil = require(DraggerFramework.Utility.JointUtil)

local JointMaker = {}
JointMaker.__index = JointMaker

function JointMaker.new(isSimulating)
	return setmetatable({
		_isSimulating = isSimulating,
	}, JointMaker)
end

local function getConstraintLength(joint)
	local a = joint.Attachment0.WorldPosition
	local b = joint.Attachment1.WorldPosition
	return (b - a).Magnitude
end

--[[
	Set the parts to compute joints for, precomputing as much info as possible
]]
function JointMaker:pickUpParts(parts)
	local partSet = {}
	for _, part in ipairs(parts) do
		partSet[part] = true
	end
	self._partSet = partSet
	self._parts = parts
	self._rootPartSet = {} -- Intentionally empty, only needed for IK moves

	local weldConstraintsToReenableSet = {}
	local jointsToDestroy = {}
	local alreadyConnectedToSets = {}
	local initiallyTouchingSets = {}
	local internalJointSet = {}
	local springsToFixupSet = {}
	local lengthConstraintsToFixupSet = {}
	for _, part in ipairs(parts) do
		alreadyConnectedToSets[part] = {}
		for _, joint in ipairs(part:GetJoints()) do
			if joint:IsA("Constraint") then
				local other = JointUtil.getConstraintCounterpart(joint, part)
				if other then
					alreadyConnectedToSets[part][other] = true

					if joint:IsA("RopeConstraint") or
						joint:IsA("RodConstraint") then
						lengthConstraintsToFixupSet[joint] = {
							Span = getConstraintLength(joint),
							Length = joint.Length,
						}
					elseif joint:IsA("SpringConstraint") then
						springsToFixupSet[joint] = {
							Span = getConstraintLength(joint),
							FreeLength = joint.FreeLength,
						}
					end
				end
			elseif joint:IsA("JointInstance") then
				local other = JointUtil.getJointInstanceCounterpart(joint, part)
				if partSet[other] then
					internalJointSet[joint] = joint.Part1
				else
					table.insert(jointsToDestroy, joint)
				end
			elseif joint:IsA("WeldConstraint") then
				local other = JointUtil.getWeldConstraintCounterpart(joint, part)
				joint.Enabled = false
				alreadyConnectedToSets[part][other] = true
				weldConstraintsToReenableSet[joint] = true
			elseif joint:IsA("NoCollisionConstraint") then
				local other = JointUtil.getNoCollisionConstraintCounterpart(joint, part)
				alreadyConnectedToSets[part][other] = true
			end
		end

		initiallyTouchingSets[part] = {}
		for _, otherPart in ipairs(part:GetTouchingParts()) do
			initiallyTouchingSets[part][otherPart] = true
		end
	end
	self._lengthConstraintsToFixupSet = lengthConstraintsToFixupSet
	self._springsToFixupSet = springsToFixupSet
	self._internalJointSet = internalJointSet
	self._initiallyTouchingSets = initiallyTouchingSets
	self._jointsToDestroy = jointsToDestroy
	self._weldConstraintsToReenableSet = weldConstraintsToReenableSet
	self._alreadyConnectedToSets = alreadyConnectedToSets
	self._geometryCache = {}
end

function JointMaker:anchorParts()
	local toUnanchorSet = {}
	for _, part in ipairs(self._parts) do
		if not part.Anchored then
			part.Anchored = true
			toUnanchorSet[part] = true
		end
	end
	self._toUnanchorSet = toUnanchorSet
end

function JointMaker:restoreAnchored()
	if self._toUnanchorSet then
		for part, _ in pairs(self._toUnanchorSet) do
			part.Anchored = false
		end
		self._toUnanchorSet = nil
	end
end

--[[
	Break existing joints to others
]]
function JointMaker:breakJointsToOutsiders()
	for _, joint in ipairs(self._jointsToDestroy) do
		joint.Parent = nil
	end
	self._jointsToDestroy = {}
end

--[[
	Break joints between parts in the part list
]]
function JointMaker:disconnectInternalJoints()
	for joint, _ in pairs(self._internalJointSet) do
		joint.Part1 = nil
	end
end

--[[
	Reconnect the internal joints between parts with a scale
]]
function JointMaker:reconnectInternalJointsWithScale(scale)
	for joint, part1 in pairs(self._internalJointSet) do
		joint.C0 = joint.C0 + joint.C0.Position * (scale - 1)
		joint.C1 = joint.C1 + joint.C1.Position * (scale - 1)
		joint.Part1 = part1
	end
end

--[[
	Compute the candidate joint pairs for the parts at their current location.
]]
function JointMaker:computeJointPairs()
	local jointPairs = JointPairs.new(self._parts, self._partSet, self._rootPartSet,
		CFrame.new(),
		self._alreadyConnectedToSets, function(part)
			return self:_getGeometry(part)
		end)

	if self._isSimulating then
		self._geometryCache = {}
	end

	return jointPairs
end

function JointMaker:isColliding(includeInitiallyTouching)
	for _, part in ipairs(self._parts) do
		for _, otherPart in ipairs(part:GetTouchingParts()) do
			if not self._partSet[otherPart] then
				if includeInitiallyTouching or not self._initiallyTouchingSets[part][otherPart] then
					return true
				end
			end
		end
	end
	return false
end

function JointMaker:fixupConstraintLengths()
	for constraint, data in pairs(self._lengthConstraintsToFixupSet) do
		local scaledBy = getConstraintLength(constraint) / data.Span
		constraint.Length = data.Length * scaledBy
	end
	for constraint, data in pairs(self._springsToFixupSet) do
		local scaledBy = getConstraintLength(constraint) / data.Span
		constraint.FreeLength = data.FreeLength * scaledBy
	end
end

function JointMaker:putDownParts()
	for weld, _ in pairs(self._weldConstraintsToReenableSet) do
		weld.Enabled = true
	end
	self._weldConstraintsToReenableSet = nil
	self._alreadyConnectedToSets = nil
	self._geometryCache = nil
	self._parts = {}
	self._partSet = {}
end

function JointMaker:_getGeometry(part)
	if self._partSet[part] then
		-- Scaling, so our geometry might change every step
		return getGeometry(part)
	else
		local geometry = self._geometryCache[part]
		if not geometry then
			geometry = getGeometry(part)
			self._geometryCache[part] = geometry
		end
		return geometry
	end
end

return JointMaker