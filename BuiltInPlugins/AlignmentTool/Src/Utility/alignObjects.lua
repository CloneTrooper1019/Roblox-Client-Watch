local Workspace = game:GetService("Workspace")

local Plugin = script.Parent.Parent.Parent
local plugin = Plugin.Parent

local DraggerFramework = Plugin.Packages.DraggerFramework
local BoundingBox = require(DraggerFramework.Utility.BoundingBox)
local JointMaker = require(DraggerFramework.Utility.JointMaker)

local AlignmentMode = require(Plugin.Src.Utility.AlignmentMode)
local AlignmentSpace = require(Plugin.Src.Utility.AlignmentSpace)
local getAlignableObjects = require(Plugin.Src.Utility.getAlignableObjects)
local getDefaultBasisForObjects = require(Plugin.Src.Utility.getDefaultBasisForObjects)

local function getAxesMask(axes)
	return Vector3.new(
		axes.X and 1 or 0,
		axes.Y and 1 or 0,
		axes.Z and 1 or 0
	)
end

local function areJointsEnabled()
	return plugin:GetJoinMode() ~= Enum.JointCreationMode.None
end

--[[
	Align BaseParts and Models in global or local coordinates, on one or more axes.

	The mode determines whether each object is aligned with respect to its center,
	minimum, or maximum extent. It also determines the side of the target bounding
	box to align relative to.

	Params:
		table objects: Array of BasePart and Model instances.
		string space: Coordinate frame to align in (World or Local).
		table axes: Axes to align in. Map of string (X, Y, Z) -> boolean.
		string mode: Side to align to (Min, Center, or Max).
		Instance target: Optional. Part or Model to align relative to. If nil, the
			bounding box for all the objects is used.
]]
return function(objects, space, axes, mode, target)
	if #objects == 0 then
		return
	end

	local basisCFrame
	if space == AlignmentSpace.Local then
		basisCFrame = getDefaultBasisForObjects(target and {target} or objects)
	else
		basisCFrame = CFrame.new()
	end

	local boundingBoxOffset, boundingBoxSize, objectBoundingBoxes =
		BoundingBox.fromObjectsComputeAll(objects, basisCFrame)

	local targetCenter, targetSize

	if target then
		local targetBoundingBox = objectBoundingBoxes[target]
		assert(targetBoundingBox, "Missing bounding box for target")
		targetCenter = basisCFrame:VectorToWorldSpace(targetBoundingBox.offset)
		targetSize = targetBoundingBox.size
	else
		targetCenter = basisCFrame:VectorToWorldSpace(boundingBoxOffset)
		targetSize = boundingBoxSize
	end

	for _, object in ipairs(objects) do
		if object == target then
			continue
		end

		local _, allParts = getAlignableObjects({object})
		assert(#allParts, "Missing parts for alignable object")

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts(allParts)
		jointMaker:breakJointsToOutsiders()

		local objectBoundingBox = objectBoundingBoxes[object]
		assert(objectBoundingBox, "Missing bounding box for object")

		local objectCenter = basisCFrame:VectorToWorldSpace(objectBoundingBox.offset)
		local localOffset = basisCFrame:VectorToObjectSpace(targetCenter - objectCenter)

		if mode == AlignmentMode.Min then
			localOffset = localOffset - (targetSize - objectBoundingBox.size) / 2
		elseif mode == AlignmentMode.Max then
			localOffset = localOffset + (targetSize - objectBoundingBox.size) / 2
		end

		local alignmentOffset = basisCFrame:VectorToWorldSpace(localOffset * getAxesMask(axes))
		if object:IsA("PVInstance") then
			object:PivotTo(object:GetPivot() + alignmentOffset)
		end

		if areJointsEnabled() then
			local jointPairs = jointMaker:computeJointPairs()
			jointPairs:createJoints()
		end
		jointMaker:putDownParts()
	end
end
