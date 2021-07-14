--[[
	Copies a table and it's metatables.
	Used in Stylizer to prevent mutating tables that convert Symbols into color values.
--]]
local function deepCopy(t)
	if type(t) ~= "table" or type(t.render) == "function" then
		return t
	end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = deepCopy(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

return deepCopy