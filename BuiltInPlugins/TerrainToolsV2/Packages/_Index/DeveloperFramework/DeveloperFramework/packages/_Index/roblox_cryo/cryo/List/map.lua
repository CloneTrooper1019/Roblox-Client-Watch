--[[
	Create a copy of a list where each value is transformed by `callback`
]]
local function map(list, callback)
	local new = {}

	for i = 1, #list do
		new[i] = callback(list[i], i)
	end

	return new
end

return map