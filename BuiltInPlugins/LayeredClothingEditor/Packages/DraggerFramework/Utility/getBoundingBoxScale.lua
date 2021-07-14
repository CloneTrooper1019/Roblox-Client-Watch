local BoundingBoxCorners = {
	Vector3.new(0.5, 0.5, 0.5),
	Vector3.new(-0.5, 0.5, 0.5),
	Vector3.new(0.5, -0.5, 0.5),
	Vector3.new(-0.5, -0.5, 0.5),
	Vector3.new(0.5, 0.5, -0.5),
	Vector3.new(-0.5, 0.5, -0.5),
	Vector3.new(0.5, -0.5, -0.5),
	Vector3.new(-0.5, -0.5, -0.5),
}

local function getBoundingBoxScale(draggerContext, cframe, size)
	local minScale = math.huge
	for _, relativeCorner in ipairs(BoundingBoxCorners) do
		local globalCorner = cframe:PointToWorldSpace(size * relativeCorner)
		minScale = math.min(minScale, draggerContext:getHandleScale(globalCorner))
	end
	return minScale
end

return getBoundingBoxScale
