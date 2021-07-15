--[[
	The identity function, which simply returns its input parameters.

	Can be used to make it clear that a handler returns its inputs.
]]
-- TODO Luau: Support typing generic return tuple
local function identity(...)
	return ...
end

return identity