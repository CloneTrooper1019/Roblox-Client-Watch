--[[
	Takes two tables A and B, returns a new table with elements of A
	which are either not keys in B or have a different value in B
]]
return function(A, B)
	local new = {}

	for key, value in pairs(A) do
		if B[key] ~= A[key] then
			new[key] = value
		end
	end

	return new
end
