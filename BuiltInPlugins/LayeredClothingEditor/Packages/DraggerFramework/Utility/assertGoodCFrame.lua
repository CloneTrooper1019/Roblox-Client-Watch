--[[
	Check that a CFrame has "good" values. That is:
	* None of the values are NaN
	* The position values are not particularly large
	* The rotation matrix is orthonormal

	This is a general catchall to be used for DEBUGGING ONLY to investigate
	CFrames becoming corrupted in some way. There are situations where a user
	might legitimately want to have a CFrame with position values larger than
	the TEST_AREA_RADIUS, so this should not be called in production code.
]]

-- How big is the test place you're testing in?
local TEST_AREA_RADIUS = 10000

-- How close to orthonormal does the CFrame need to be?
local ORTHONORMAL_EPSILON = 0.001

return function(cframe)
	local x, y, z,
		d, e, f,
		g, h, i,
		j, k, l = cframe:GetComponents()
	-- Note: For IEEE floating point NaNs, NaN == NaN is false.
	-- We use that here to check for NaNs.
	if x ~= x or y ~= y or z ~= z or
		d ~= d or e ~= e or f ~= f or
		g ~= g or h ~= h or i ~= i or
		j ~= j or k ~= k or l ~= l then
		error("Bad CFrame: "..tostring(cframe))
	end
	if math.abs(x) + math.abs(y) + math.abs(z) > TEST_AREA_RADIUS * 3 then
		error("Big CFrame: "..tostring(cframe))
	end
	local right = cframe.RightVector
	local top = cframe.UpVector
	local back = cframe.LookVector
	if math.abs(right:Dot(top)) > ORTHONORMAL_EPSILON or
		math.abs(top:Dot(back)) > ORTHONORMAL_EPSILON or
		math.abs(back:Dot(right)) > ORTHONORMAL_EPSILON then
		error("Non orthogonal CFrame: "..tostring(cframe))
	end
	if math.abs(1 - right.Magnitude) > ORTHONORMAL_EPSILON or
		math.abs(1 - top.Magnitude) > ORTHONORMAL_EPSILON or
		math.abs(1 - back.Magnitude) > ORTHONORMAL_EPSILON then
		error("Non unitary units: "..tostring(cframe))
	end
end