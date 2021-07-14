--[[
	Returns `true` if the _left_ and _right_ values are equal (by the equality operator) or the
	inputs are tables, and all their keys are equal.
]]
local function shallowEqual(left: any, right: any)
	if left == right then
		return true
	end
	if typeof(left) ~= "table" or typeof(right) ~= "table" or #left ~= #right then
		return false
	end
	if left == nil or right == nil then
		return false
	end
	for key, value in pairs(left) do
		if right[key] ~= value then
			return false
		end
	end
	for key, value in pairs(right) do
		if left[key] ~= value then
			return false
		end
	end
	return true
end

return shallowEqual
