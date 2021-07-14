--[[
	Returns a new list containing only the elements within the given range.
]]

local function getRange(list, startIndex, endIndex)
	assert(startIndex <= endIndex, "startIndex must be less than or equal to endIndex")

	local new = {}
	local index = 1

	for i = math.max(1, startIndex), math.min(#list, endIndex) do
		new[index] = list[i]
		index = index + 1
	end

	return new
end

return getRange