--[[
	Returns a list of the keys from the given dictionary.
]]
local function keys(dictionary)
	local new = {}
	local index = 1

	for key in pairs(dictionary) do
		new[index] = key
		index = index + 1
	end

	return new
end

return keys