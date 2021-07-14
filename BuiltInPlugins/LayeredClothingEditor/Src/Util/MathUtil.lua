local MathUtil = {}

function MathUtil:fuzzyEq(a, b)
	local epsilon = 0.001
	return math.abs(a - b) < epsilon
end

function MathUtil:fuzzyEq_Vector3(vec1, vec2)
	return	MathUtil:fuzzyEq(vec1.X, vec2.X) and
			MathUtil:fuzzyEq(vec1.Y, vec2.Y) and
			MathUtil:fuzzyEq(vec1.Z, vec2.Z)
end

function MathUtil:adornLocalSpace(adornee, position)
	return adornee.CFrame:inverse() * CFrame.new(position)
end

function MathUtil:pointInRect(point, p1, p2, width, height)
	if point.X >= p1.X and point.X <= p1.X + width
		and point.Y >= p2.Y and point.Y <= p2.Y + height then
		return true
	end
	return false
end

return MathUtil