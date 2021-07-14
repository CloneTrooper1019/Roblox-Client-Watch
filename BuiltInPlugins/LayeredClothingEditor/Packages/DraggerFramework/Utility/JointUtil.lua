local JointUtil = {}

local DraggerFramework = script.Parent.Parent

local getFFlagDraggerPerf = require(DraggerFramework.Flags.getFFlagDraggerPerf)

if getFFlagDraggerPerf() then
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
else
	function JointUtil.getConstraintCounterpart(constraint, part)
		if constraint.Attachment0 and constraint.Attachment0.Parent == part then
			return constraint.Attachment1 and constraint.Attachment1.Parent or nil
		else
			return constraint.Attachment0 and constraint.Attachment0.Parent or nil
		end
	end

	function JointUtil.getJointInstanceCounterpart(joint, part)
		if joint.Part0 == part then
			return joint.Part1
		else
			return joint.Part0
		end
	end

	function JointUtil.getWeldConstraintCounterpart(weldConstraint, part)
		if weldConstraint.Part0 == part then
			return weldConstraint.Part1
		else
			return weldConstraint.Part0
		end
	end

	function JointUtil.getNoCollisionConstraintCounterpart(weldConstraint, part)
		if weldConstraint.Part0 == part then
			return weldConstraint.Part1
		else
			return weldConstraint.Part0
		end
	end
end

return JointUtil