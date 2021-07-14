--[[
	Returns a new list, ordered with the given sort callback.
	If no callback is given, the default table.sort will be used.
]]

local function sort(list, callback)
	local new = {}

	for i = 1, #list do
		new[i] = list[i]
	end

	table.sort(new, callback)

	return new
end

return sort