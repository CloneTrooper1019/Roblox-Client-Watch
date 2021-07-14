--[[
	roundRotation(CFrame) -> CFrame

	Round a rotation CFrame which is approximately primary axis aligned to be
	exactly primary axis aligned instead (such that all of its components are
	-1, 0, or 1).

	Will not work on an arbitrary CFrame! This function is intended to be used
	on CFrames which within a small amount of floating point error of already
	being aligned.
]]
return function(cframe)
	local x, y, z,
		r0, r1, r2,
		r3, r4, r5,
		r6, r7, r8 = cframe:components()
	assert(x == 0 and y == 0 and z == 0)
	return CFrame.new(0, 0, 0,
		math.floor(r0 + 0.5), math.floor(r1 + 0.5), math.floor(r2 + 0.5),
		math.floor(r3 + 0.5), math.floor(r4 + 0.5), math.floor(r5 + 0.5),
		math.floor(r6 + 0.5), math.floor(r7 + 0.5), math.floor(r8 + 0.5))
end