local JointUtil = {}

function JointUtil.getConstraintCounterpart(constraint, part)
	-- Ugly micro-optimized code because this function gets hit in hot paths
	-- The micro-optimized version saves 3-4ms on some actions over the
	-- unoptimized variant.
	local attachment0 = constraint.Attachment0
	if attachment0 then
		local attachment0Parent = attachment0.Parent
		if attachment0Parent == part then
			local attachment1 = constraint.Attachment1
			return attachment1 and attachment1.Parent
		else
			return attachment0Parent
		end
	else
		local attachment1 = constraint.Attachment1
		return attachment1 and attachment1.Parent
	end
end

function JointUtil.getJointInstanceCounterpart(joint, part)
	local part0 = joint.Part0
	if part0 == part then
		return joint.Part1
	else
		return part0
	end
end

function JointUtil.getWeldConstraintCounterpart(weldConstraint, part)
	local part0 = weldConstraint.Part0
	if part0 == part then
		return weldConstraint.Part1
	else
		return part0
	end
end

function JointUtil.getNoCollisionConstraintCounterpart(noCollisionConstraint, part)
	local part0 = noCollisionConstraint.Part0
	if part0 == part then
		return noCollisionConstraint.Part1
	else
		return part0
	end
end

return JointUtil