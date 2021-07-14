--[[
	Remove the range from the list starting from the index.
]]
local function removeRange(list, startIndex, endIndex)
	assert(startIndex <= endIndex, "startIndex must be less than or equal to endIndex")

	local new = {}
	local index = 1

	for i = 1, math.min(#list, startIndex - 1) do
		new[index] = list[i]
		index = index + 1
	end

	for i = endIndex + 1, #list do
		new[index] = list[i]
		index = index + 1
	end

	return new
end

return removeRange