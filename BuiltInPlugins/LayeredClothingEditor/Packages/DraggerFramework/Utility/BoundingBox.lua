local Workspace = game:GetService("Workspace")

local function getBoundingBoxInternal(cframe, size, inverseBasis)
	local localCFrame = inverseBasis and (inverseBasis * cframe) or cframe
	local sx, sy, sz = size.X, size.Y, size.Z

	local _, _, _,
		t00, t01, t02,
		t10, t11, t12,
		t20, t21, t22 = localCFrame:GetComponents()
	local hw = 0.5 * (math.abs(sx * t00) + math.abs(sy * t01) + math.abs(sz * t02))
	local hh = 0.5 * (math.abs(sx * t10) + math.abs(sy * t11) + math.abs(sz * t12))
	local hd = 0.5 * (math.abs(sx * t20) + math.abs(sy * t21) + math.abs(sz * t22))
	local x, y, z = localCFrame.X, localCFrame.Y, localCFrame.Z

	local xmin = x - hw
	local xmax = x + hw
	local ymin = y - hh
	local ymax = y + hh
	local zmin = z - hd
	local zmax = z + hd

	return xmin, xmax, ymin, ymax, zmin, zmax
end

local BoundingBox = {}

--[[
	Returns the bounding box that contains the specified objects.

	The bounding box is computed in the given coordinate space, or world space if
	no local basis is provided.

	Params:
		table objects: An array of BaseParts, Models, and Attachments.
		CFrame basisCFrame: Optional local basis.

	Returns:
		Tuple (Vector3 offset, Vector3 size).
]]
function BoundingBox.fromObjects(objects, basisCFrame)
	local inverseBasis = basisCFrame and basisCFrame:Inverse() or nil
	local xmin, xmax = math.huge, -math.huge
	local ymin, ymax = math.huge, -math.huge
	local zmin, zmax = math.huge, -math.huge

	local terrain = Workspace.Terrain

	for _, object in ipairs(objects) do
		local isModel = object:IsA("Model")
		if isModel or (object:IsA("BasePart") and object ~= terrain) then
			local cframe, size
			if isModel then
				cframe, size = object:GetBoundingBox()
			else
				cframe = object.CFrame
				size = object.Size
			end

			local xmin1, xmax1, ymin1, ymax1, zmin1, zmax1 = getBoundingBoxInternal(
				cframe, size, inverseBasis)

			xmin = math.min(xmin, xmin1)
			xmax = math.max(xmax, xmax1)
			ymin = math.min(ymin, ymin1)
			ymax = math.max(ymax, ymax1)
			zmin = math.min(zmin, zmin1)
			zmax = math.max(zmax, zmax1)
		elseif object:IsA("Attachment") then
			local localPosition = basisCFrame:PointToObjectSpace(object.WorldPosition)
			local x, y, z = localPosition.X, localPosition.Y, localPosition.Z
			xmin = math.min(xmin, x)
			xmax = math.max(xmax, x)
			ymin = math.min(ymin, y)
			ymax = math.max(ymax, y)
			zmin = math.min(zmin, z)
			zmax = math.max(zmax, z)
		end
	end

	local offset = Vector3.new(
		0.5 * (xmin + xmax),
		0.5 * (ymin + ymax),
		0.5 * (zmin + zmax)
	)
	local size = Vector3.new(
		xmax - xmin,
		ymax - ymin,
		zmax - zmin
	)

	return offset, size
end

--[[
	Returns the bounding box that contains the specified objects, as well as the
	bounding boxes for all BaseParts and Models.

	Bounding boxes are computed in the given coordinate space, or world space if
	no local basis is provided.

	Params:
		table objects: An array of BaseParts, Models, and Attachments.
		CFrame basisCFrame: Optional local basis.

	Returns:
		Tuple (Vector3 offset, Vector3 size, table boundingBoxes).
]]
function BoundingBox.fromObjectsComputeAll(objects, basisCFrame)
	local inverseBasis = basisCFrame and basisCFrame:Inverse() or nil
	local xmin, xmax = math.huge, -math.huge
	local ymin, ymax = math.huge, -math.huge
	local zmin, zmax = math.huge, -math.huge

	local terrain = Workspace.Terrain

	local boundingBoxes = {}

	for _, object in ipairs(objects) do
		local isModel = object:IsA("Model")
		if isModel or object:IsA("BasePart") and object ~= terrain then
			local cframe, size
			if isModel then
				cframe, size = object:GetBoundingBox()
			else
				cframe = object.CFrame
				size = object.Size
			end

			local xmin1, xmax1, ymin1, ymax1, zmin1, zmax1 = getBoundingBoxInternal(
				cframe, size, inverseBasis)

			xmin = math.min(xmin, xmin1)
			xmax = math.max(xmax, xmax1)
			ymin = math.min(ymin, ymin1)
			ymax = math.max(ymax, ymax1)
			zmin = math.min(zmin, zmin1)
			zmax = math.max(zmax, zmax1)

			boundingBoxes[object] = {
				offset = Vector3.new(
					0.5 * (xmin1 + xmax1),
					0.5 * (ymin1 + ymax1),
					0.5 * (zmin1 + zmax1)
				),
				size = Vector3.new(
					xmax1 - xmin1,
					ymax1 - ymin1,
					zmax1 - zmin1
				)
			}
		elseif object:IsA("Attachment") then
			local localPosition = basisCFrame:PointToObjectSpace(object.WorldPosition)
			local x, y, z = localPosition.X, localPosition.Y, localPosition.Z
			xmin = math.min(xmin, x)
			xmax = math.max(xmax, x)
			ymin = math.min(ymin, y)
			ymax = math.max(ymax, y)
			zmin = math.min(zmin, z)
			zmax = math.max(zmax, z)
		end
	end

	local offset = Vector3.new(
		0.5 * (xmin + xmax),
		0.5 * (ymin + ymax),
		0.5 * (zmin + zmax)
	)
	local size = Vector3.new(
		xmax - xmin,
		ymax - ymin,
		zmax - zmin
	)

	return offset, size, boundingBoxes
end

--[[
	Calculate an oriented bounding box for the passed in parts and attachments,
	in the supplied basis.
]]
function BoundingBox.fromPartsAndAttachments(parts, attachments, basisCFrame)
	local inverseBasis = basisCFrame and basisCFrame:Inverse() or nil
	local xmin, xmax = math.huge, -math.huge
	local ymin, ymax = math.huge, -math.huge
	local zmin, zmax = math.huge, -math.huge

	local terrain = Workspace.Terrain

	for _, part in ipairs(parts) do
		if part ~= terrain then
			local xmin1, xmax1,
				ymin1, ymax1,
				zmin1, zmax1 = getBoundingBoxInternal(part.CFrame, part.Size, inverseBasis)

			xmin = math.min(xmin, xmin1)
			xmax = math.max(xmax, xmax1)
			ymin = math.min(ymin, ymin1)
			ymax = math.max(ymax, ymax1)
			zmin = math.min(zmin, zmin1)
			zmax = math.max(zmax, zmax1)
		end
	end

	for _, attachment in ipairs(attachments) do
		local localPosition = basisCFrame:PointToObjectSpace(attachment.WorldPosition)
		local x, y, z = localPosition.X, localPosition.Y, localPosition.Z
		xmin = math.min(xmin, x)
		xmax = math.max(xmax, x)
		ymin = math.min(ymin, y)
		ymax = math.max(ymax, y)
		zmin = math.min(zmin, z)
		zmax = math.max(zmax, z)
	end

	local offset = Vector3.new(
		0.5 * (xmin + xmax),
		0.5 * (ymin + ymax),
		0.5 * (zmin + zmax)
	)
	local size = Vector3.new(
		xmax - xmin,
		ymax - ymin,
		zmax - zmin
	)

	return offset, size
end

return BoundingBox
