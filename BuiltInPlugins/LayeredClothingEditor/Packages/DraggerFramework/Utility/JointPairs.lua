local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local Plugin = DraggerFramework.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Colors = require(DraggerFramework.Utility.Colors)
local Math = require(DraggerFramework.Utility.Math)

local JointPairs = {}
JointPairs.__index = JointPairs

local SurfaceTypeToJointType = {
	[Enum.SurfaceType.Hinge] = "Rotate",
	[Enum.SurfaceType.Motor] = "RotateV",
	[Enum.SurfaceType.SteppingMotor] = "RotateP",
}

local JointTypeToColor = {
	Rotate = Colors.RotatingJoint,
	RotateV = Colors.RotatingJoint,
	RotateP = Colors.RotatingJoint,
	Weld = Colors.WeldJoint,
	None = Colors.InvalidJoint,
}

--[[
	How far away from a part to look for other parts to join to. This is purely
	an optimization setting, as long as it is larger than JOINT_TOLERANCE it
	won't change the PartMover behavior.
]]
local FUZZY_TOLERANCE = 0.1

--[[
	How close together the parallel faces of two parts have to be for a joint
	to be made between them.
]]
local JOINT_TOLERANCE = 0.05

--[[
	How close the dot product of two face normals has to be for a joint to be
	made between them.
]]
local JOINT_ANGLE_TOLERANCE = 0.001

local function isVertexInFace(vert, face, normal)
	for i = 1, #face do
		local e1, e2;
		if i == 1 then
			e1 = face[#face]
			e2 = face[1]
		else
			e1 = face[i - 1]
			e2 = face[i]
		end
		local edge = e2 - e1
		local to = vert - e1
		-- TODO: Fix this. For very large parts this will lead to erroneous
		-- misses because we're comparing to an angle tolerance rather than
		-- a distance tolerance by having a tolerance here
		if edge:Cross(to):Dot(normal) < 0.01 then
			return false
		end
	end
	return true
end

local function faceHasVertsInFace(face, containingFace, normal)
	for _, vert in ipairs(face) do
		if isVertexInFace(vert, containingFace, normal) then
			return true
		end
	end
	return false
end

local function edgeIntersectsEdge(a1, a2, b1, b2, bnormal)
	local arun, brun = (a2 - a1), (b2 - b1)
	local alen, blen = arun.Magnitude, brun.Magnitude
	local edgeDot = arun:Dot(brun) / alen / blen
	local athres = 0.01 / alen
	local bthres = 0.01 / blen

	--[[
		More common case, edges coincident over a non-zero length section.
		We also have a consistent winding direction on our geometry, so if the
		edges are going in the same direction, they are from an edge that is
		touching but not thanks to a touching face. For example:
		[]
		  [] Those two blocks touch at one edge, but not at any faces.
	]]
	if math.abs(math.abs(edgeDot) - 1) < 0.0001 then
		--parallel case
		if edgeDot > 0 then
			-- They are going in the same direction, they can't be
			-- an edge pair to join on
			return false
		else
			-- They are going in opposite directions, this might be an exactly
			-- coincident edge.

			-- First check if they are cooincident
			local inB = (a1 - b1):Dot(brun) / blen / blen
			local dist = (a1 - (b1 + inB * brun)).Magnitude
			if dist > 0.001 then
				return false
			end

			-- Now we need to see if they overlap
			local inB2 = (a2 - b1):Dot(brun) / blen / blen
			local interval = math.clamp(inB, 0, 1) - math.clamp(inB2, 0, 1)
			return interval > 0.001 -- They are coincident and share an interval
		end
	end

	--[[
		Less common case, edges that cross one and other. Imagine two long thin
		parts arranged in an X shape. They should be joined, and that joint comes
		from this case, where their edges intersect at the middle of the X.
	]]
	local intersects, s = Math.intersectRayRay(a1, arun, b1, brun)
	if not intersects or s < athres or s > 1 - athres then
		return false
	end
	local intersects2, t = Math.intersectRayRay(b1, brun, a1, arun)
	assert(intersects2) -- Must be true if intersects was true
	return t >= bthres and t <= 1 - bthres
end

local function edgesIntersectsEdges(face, otherFace, otherNormal)
	for i = 1, #face do
		local a1, a2;
		if i == 1 then
			a1, a2 = face[#face], face[1]
		else
			a1, a2 = face[i - 1], face[i]
		end
		for j = 1, #otherFace do
			local b1, b2;
			if j == 1 then
				b1, b2 = otherFace[#otherFace], otherFace[1]
			else
				b1, b2 = otherFace[j - 1], otherFace[j]
			end
			if edgeIntersectsEdge(a1, a2, b1, b2, otherNormal) then
				return true
			end
		end
	end
	return false
end

local function canMakeJointBetweenFaces(part, face, otherPart, otherFace, otherNormal)
	-- Can join if there are any touching faces. This can be divided into:
	-- 1. Obviously touching if verts of one face are contained in the other face
	-- 2. If edges of one face intersect the other, for example, when two long
	--	parts are arranged in an X shape.
	return faceHasVertsInFace(face.vertices, otherFace.vertices, otherNormal) or
		faceHasVertsInFace(otherFace.vertices, face.vertices, -otherNormal) or
		edgesIntersectsEdges(face.vertices, otherFace.vertices, otherNormal)
end

local function getFaceCenter(face)
	if not face.center then
		local total = Vector3.new()
		for _, vert in ipairs(face.vertices) do
			total = total + vert
		end
		face.center = total / #face.vertices
	end
	return face.center
end

local function buildJoint(part0, face0, part1, jointType)
	-- Determine the C0 and C1 for the joint. Center it around the center of
	-- the relevant face, since that's where the surface axis gizmo appears.
	local centerCFrame =
		CFrame.fromMatrix(
			getFaceCenter(face0),
			face0.direction, face0.normal:Cross(face0.direction))
	return {
		ClassName = jointType,
		Part0 = part0,
		C0 = part0.CFrame:Inverse() * centerCFrame,
		Part1 = part1,
		C1 = part1.CFrame:Inverse() * centerCFrame,
	}
end

local function buildInvalidJoint()
	return {
		ClassName = "None",
	}
end

--[[
	Called once we already know that there is a joint between two faces, but
	don't know what _kind_ of joint it is yet or which part will be the
	part0 and which will be the part1.

	`part` is the part being moved, and its face surface type takes priority
	as far as determining the type of joint.
]]
local function buildAppropriateJoint(part, otherPart, shape, otherShape, face, otherFace)
	local isFaceAcceptable =
		(shape == "Mesh") or
		(shape == "Cylinder" and
			(face.surface == "RightSurface" or face.surface == "LeftSurface"))

	local isOtherFaceAcceptable =
		(otherShape == "Mesh") or
		(otherShape == "Cylinder" and
			(otherFace.surface == "RightSurface" or otherFace.surface == "LeftSurface"))

	if isFaceAcceptable and isOtherFaceAcceptable then
		return buildJoint(part, face, otherPart, "Weld")
	else
		-- Only planar meshes and the flat ends of cylinders are allowed to
		-- form surface welds.
		return nil
	end
end

--[[
	Check if a joint is possible between two specific parts and return the joint
	if there is a possible joint.
	Updates facesToHighlightSet with both the possible joint if there is one,
	and with an invalid joint if there's touching faces that can't be joined.
]]
local function tryToCreateJointPair(transform, part, otherPart, facesToHighlightSet,
	getGeometryFunction, isAHumanoidModelFunction)
	local partGeometry = getGeometryFunction(part)
	local otherGeometry = getGeometryFunction(otherPart)

	-- Transform faces of the
	local tempTransformedFaces = {}

	-- Easy case first, just handle mesh-mesh for now
	for _, partFace in ipairs(partGeometry.faces) do
		for _, otherFace in ipairs(otherGeometry.faces) do
			local transformedNormal = transform:VectorToWorldSpace(partFace.normal)
			local transformedDirection = transform:VectorToWorldSpace(partFace.direction)
			local dot = transformedNormal:Dot(otherFace.normal)
			if dot < -(1 - JOINT_ANGLE_TOLERANCE) then
				local newPoint = transform:PointToWorldSpace(partFace.point)
				local dist = (newPoint - otherFace.point):Dot(otherFace.normal)
				if math.abs(dist) < JOINT_TOLERANCE then
					local tempTransformedFace = tempTransformedFaces[partFace]
					if not tempTransformedFace then
						local transformedFaceVerts = {}
						for _, vertex in ipairs(partFace.vertices) do
							table.insert(transformedFaceVerts, transform * vertex)
						end
						tempTransformedFace = {
							id = partFace.id,
							vertices = transformedFaceVerts,
							normal = transformedNormal,
							direction = transformedDirection,
							surface = partFace.surface,
							-- Note: There are more fields, we're only copying
							-- over the modified ones we need.
						}
						tempTransformedFaces[partFace] = tempTransformedFace
					end
					local canJoin = canMakeJointBetweenFaces(
						part, tempTransformedFace,
						otherPart, otherFace,
						otherFace.normal)
					if canJoin then
						-- The faces are aligned and close to cooincident
						local joint = buildAppropriateJoint(
							part, otherPart,
							partGeometry.shape, otherGeometry.shape,
							tempTransformedFace, otherFace)
						if joint and not isAHumanoidModelFunction(part.Parent) and
							not isAHumanoidModelFunction(otherPart.Parent) then
							-- This if exists because of the extra weird case of
							-- surface hinges/motors blocking joints on the rest
							-- of the surface that they're on.
							-- Also block joints between parts when either part
							-- is inside of a humanoid.
							facesToHighlightSet[tempTransformedFace] = joint
							facesToHighlightSet[otherFace] = joint
							return true, joint
						else
							-- If the joint doesn't exist, we draw an invalid
							-- joint pair (red) between the parts.
							joint = buildInvalidJoint()
							facesToHighlightSet[tempTransformedFace] = joint
							facesToHighlightSet[otherFace] = joint
							return false
						end
					end
				end
			end
		end
	end
	return false
end

--[[
	Compute the joint pairs between a collection of parts and the rest of the
	world. Return a JointPairs object storing information about the computed
	joints for further use.

	partList - A list of the parts
	partSet -- The same parts, organized as a set rather than a list.
	rootPartSet -- A set of the root parts of the parts in the partList.
	globalTransform --
		A transform to apply to the partSet, including any getGeometry results
		returned for them.
	alreadyConnectedToSets --
		alreadyConnectedToSets[part][otherPart] is true if part and other are
		already connected with a joint.
	getGeometryFunction --
		A function that takes a part and returns the getGeometry() for it.
]]
function JointPairs.new(partList, partSet, rootPartSet, globalTransform, alreadyConnectedToSets, getGeometryFunction)
	local self = setmetatable({}, JointPairs)

	local isAHumanoidModel = {}
	local function isAHumanoidModelFunction(object)
		if not object then
			return false
		end
		local status = isAHumanoidModel[object]
		if not status then
			status =
				(object:FindFirstChildWhichIsA("Humanoid") ~= nil) or
				isAHumanoidModelFunction(object.Parent)
			isAHumanoidModel[object] = status
		end
		return status
	end

	local terrain = Workspace.Terrain
	local facesToHighlightSet = {}
	local jointPairs = {}

	for _, part in ipairs(partList) do
		local radius = part.Size.Magnitude / 2
		local radiusVector =
			Vector3.new(radius + FUZZY_TOLERANCE, radius + FUZZY_TOLERANCE, radius + FUZZY_TOLERANCE)
		local nearbyParts = Workspace:FindPartsInRegion3WithIgnoreList(
			Region3.new(part.Position - radiusVector, part.Position + radiusVector),
			{}, --partList could go here but costs too much to repeatedly reflect
			10000)

		-- Terrain joint case. If we are touching the terrain at all then
		-- create a joint pair with it, regardless of surface geometry.
		for _, touchingPart in ipairs(part:GetTouchingParts()) do
			if touchingPart == terrain then
				if not alreadyConnectedToSets[part][terrain] then
					table.insert(jointPairs, {
						ClassName = "Weld",
						C0 = CFrame.new(),
						C1 = part.CFrame,
						Part0 = part,
						Part1 = terrain,
					})
				end
				break
			end
		end

		for _, otherPart in ipairs(nearbyParts) do
			if not partSet[otherPart] and not rootPartSet[otherPart:GetRootPart()] then
				if otherPart ~= terrain then
					local otherRadius = otherPart.Size.Magnitude / 2
					if (otherPart.Position - part.Position).Magnitude <= (radius + otherRadius) + JOINT_TOLERANCE then
						-- This is a very uncommon condition (happens only for
						-- constraints joining a part in the selection and
						-- one not in the selection and only when those two parts
						-- are touching) which is why I put it innermost.
						if not alreadyConnectedToSets[part][otherPart] then
							local success, joint = tryToCreateJointPair(globalTransform,
								part, otherPart,
								facesToHighlightSet,
								getGeometryFunction, isAHumanoidModelFunction)
							if success then
								table.insert(jointPairs, joint)
							end
						end
					end
				end
			end
		end
	end

	self._jointPairs = jointPairs
	self._facesToHighlightSet = facesToHighlightSet

	return self
end

--[[
	Return a Roact component visually displaying the joint pairs to be created.
]]
function JointPairs:renderJoints(scale)
	local faceViews = {}
	for face, joint in pairs(self._facesToHighlightSet) do
		local edgeViews = {}
		for i = 1, #face.vertices do
			local v0, v1;
			if i == 1 then
				v0, v1 = face.vertices[#face.vertices], face.vertices[1]
			else
				v0, v1 = face.vertices[i - 1], face.vertices[i]
			end
			local edgeLength = (v0 - v1).Magnitude
			edgeViews[i] = Roact.createElement("CylinderHandleAdornment", {
				CFrame = CFrame.new(v0, v1) * CFrame.new(0, 0, -edgeLength / 2) * CFrame.Angles(0, 0, math.pi / 2),
				Color3 = JointTypeToColor[joint.ClassName],
				Radius = 0.05 + 0.05 * scale,
				Height = edgeLength,
				Adornee = Workspace.Terrain
			})
		end

		-- Using the face table's hash as key here. There's no other good way to
		-- uniquely identify the face, because they key is really the part that
		-- the face is being shown for, but we can't use a part as a key here.
		faceViews[tostring(face)] = Roact.createElement("Folder", {}, edgeViews)
	end
	return Roact.createFragment(faceViews)
end

--[[
	Create the joint pairs and parent them to the Workspace.
]]
function JointPairs:createJoints()
	for _, joint in ipairs(self._jointPairs) do
		local jointInstance = Instance.new(joint.ClassName)
		jointInstance.Part0 = joint.Part0
		jointInstance.C0 = joint.C0
		jointInstance.Part1 = joint.Part1
		jointInstance.C1 = joint.C1
		jointInstance.Parent = joint.Part0
	end
end

return JointPairs