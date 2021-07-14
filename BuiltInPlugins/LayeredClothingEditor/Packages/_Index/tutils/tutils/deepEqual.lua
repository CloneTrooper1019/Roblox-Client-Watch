--[[
	Takes two tables A and B, returns if they are deeply equal. ignoreMetatables specifies if metatables should be ignored
	in the deep compare
	Assumes tables do not have self-references
]]

local function deepEqual(A, B, ignoreMetatables)
	if A == B then
		return true
	end
	local AType = type(A)
	local BType = type(B)
	if AType ~= BType then
		return false
	end
	if AType ~= "table" then
		return false
	end

	if not ignoreMetatables then
		local mt1 = getmetatable(A)
		if mt1 and mt1.__eq then
			--compare using built in method
			return A == B
		end
	end

	local keySet = {}

	for key1, value1 in pairs(A) do
		local value2 = B[key1]
		if value2 == nil or not deepEqual(value1, value2, ignoreMetatables) then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(B) do
		if not keySet[key2] then
			return false
		end
	end
	return true
end

return deepEqual
