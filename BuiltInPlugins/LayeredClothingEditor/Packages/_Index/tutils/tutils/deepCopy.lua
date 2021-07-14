--[[
	Returns a deep copy of the given table.
	Both the keys and the values of the table are deep copied.
	Metatable of the table is copied.
	If table is used as key in the input table,
	the deep copy will not be deepEqual to the original.
]]

local function deepCopy(A, seen)
	if type(A) ~= 'table' then
		return A
	end

	if seen and seen[A] then
		return seen[A]
	end

	local alreadySeen  = seen or {}
	local newTable = setmetatable({}, getmetatable(A))
	alreadySeen[A] = newTable
	for key, value in pairs(A) do
		newTable[deepCopy(key, alreadySeen)] = deepCopy(value, alreadySeen)
	end
	return newTable
end

return deepCopy
