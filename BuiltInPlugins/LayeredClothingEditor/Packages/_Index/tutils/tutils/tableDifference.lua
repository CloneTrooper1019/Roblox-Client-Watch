--[[
	Takes two tables A and B, returns a new table with elements of A
	which are either not keys in B or have a different value in B
]]
return function(A, B)
	local new = {}

	for keyA, valueA in pairs(A) do
		if B[keyA] ~= A[keyA] then
			new[keyA] = valueA
		end
	end

	for keyB, valueB in pairs(B) do
		if B[keyB] ~= A[keyB] then
			new[keyB] = valueB
		end
	end

	return new
end
