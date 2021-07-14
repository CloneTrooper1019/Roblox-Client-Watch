local DraggerFramework = script.Parent.Parent

local getFFlagOnlyGetGeometryOnce = require(DraggerFramework.Flags.getFFlagOnlyGetGeometryOnce)

local PrimaryDirections = {
	Vector3.new(1, 0, 0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 1, 0),
	Vector3.new(0, -1, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 0, -1)
}

local function largestComponent(vector)
	return math.max(math.abs(vector.X), math.abs(vector.Y), math.abs(vector.Z))
end

local function snapVectorToPrimaryDirection(direction)
	local largestDot = -math.huge
	local closestDirection
	if getFFlagOnlyGetGeometryOnce() then
		-- Start with direction as an escape hatch in case of Inf/NaN
		closestDirection = direction
	end
	for _, target in ipairs(PrimaryDirections) do
		local dot = direction:Dot(target)
		if dot > largestDot then
			largestDot = dot
			closestDirection = target
		end
	end
	return closestDirection
end

return function(cframe)
	local right = cframe.RightVector
	local top = cframe.UpVector
	local front = -cframe.LookVector
	local largestRight = largestComponent(right)
	local largestTop = largestComponent(top)
	local largestFront = largestComponent(front)
	if largestRight > largestTop and largestRight > largestFront then
		-- Most aligned axis is X, the right, preserve that
		right = snapVectorToPrimaryDirection(right)
		if largestTop > largestFront then
			top = snapVectorToPrimaryDirection(top)
		else
			local front = snapVectorToPrimaryDirection(front)
			top = front:Cross(right).Unit
		end
	elseif largestTop > largestFront then
		-- Most aligned axis is Y, the top, preserve that
		top = snapVectorToPrimaryDirection(top)
		if largestRight > largestFront then
			right = snapVectorToPrimaryDirection(right)
		else
			local front = snapVectorToPrimaryDirection(front)
			right = top:Cross(front).Unit
		end
	else
		-- Most aligned axis is Z, the front, preserve that
		local front = snapVectorToPrimaryDirection(front)
		if largestRight > largestTop then
			right = snapVectorToPrimaryDirection(right)
			top = front:Cross(right).Unit
		else
			top = snapVectorToPrimaryDirection(top)
			right = top:Cross(front).Unit
		end
	end
	return CFrame.fromMatrix(Vector3.new(), right, top)
end