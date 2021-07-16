--[[
	Remove the element at the given index.
]]
local function removeIndex(list, index)
	local new = {}
	local removed = 0

	for i = 1, #list do
		if i == index then
			removed = 1
		else
			new[i - removed] = list[i]
		end
	end

	return new
end

return removeIndex