--[[
	Takes a table and returns the field count
]]
return function(t)
	local fieldCount = 0
	for _ in pairs(t) do
		fieldCount = fieldCount + 1
	end
	return fieldCount
end