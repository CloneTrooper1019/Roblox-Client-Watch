--[[
	Returns the index of the first value found or nil if not found.
]]

local function find(list, value)
	for i = 1, #list do
		if list[i] == value then
			return i
		end
	end
	return nil
end

return find