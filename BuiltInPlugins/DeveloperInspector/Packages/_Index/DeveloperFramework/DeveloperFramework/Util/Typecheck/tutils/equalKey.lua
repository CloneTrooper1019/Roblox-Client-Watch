--[[
	Takes two tables A, B and a key, returns if two tables have the same value at key
]]

return function(A, B, key)
	if A and B and key and key ~= "" and A[key] and B[key] and A[key] == B[key] then
		return true
	end
	return false
end