--[[
	Takes two tables A and B, returns if they have the same key-value pairs
	Except ignored keys
]]
return function(A, B, ignore)
	if not A or not B then
		return false
	elseif A == B then
		return true
	end
	if not ignore then
		ignore = {}
	end

	for key, value in pairs(A) do
		if B[key] ~= value and not ignore[key] then
			return false
		end
	end
	for key, value in pairs(B) do
		if A[key] ~= value and not ignore[key] then
			return false
		end
	end

	return true
end