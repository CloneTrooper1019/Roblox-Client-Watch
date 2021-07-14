--[[
	Returns a new list with the new value replaced at the given index.
]]

local function replaceIndex(list, index, value)
	local new = {}
	local len = #list

	assert(index <= len, "index must be less or equal than the list length")

	for i = 1, len do
		if i == index then
			new[i] = value
		else
			new[i] = list[i]
		end
	end

	return new
end

return replaceIndex