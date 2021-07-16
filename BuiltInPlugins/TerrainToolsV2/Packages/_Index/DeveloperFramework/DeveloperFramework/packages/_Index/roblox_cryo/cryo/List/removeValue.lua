--[[
	Creates a new list that has no occurrences of the given value.
]]
local function removeValue(list, value)
	local new = {}
	local index = 1

	for i = 1, #list do
		if list[i] ~= value then
			new[index] = list[i]
			index = index + 1
		end
	end

	return new
end

return removeValue