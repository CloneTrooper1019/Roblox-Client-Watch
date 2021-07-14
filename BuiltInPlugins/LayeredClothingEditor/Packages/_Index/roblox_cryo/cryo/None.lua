--[[
	Represents a value that is intentionally present, but should be interpreted
	as `nil`.

	Cryo.None is used by included utilities to make removing values more
	ergonomic.
]]

local None = newproxy(true)

getmetatable(None).__tostring = function()
	return "Cryo.None"
end

return None