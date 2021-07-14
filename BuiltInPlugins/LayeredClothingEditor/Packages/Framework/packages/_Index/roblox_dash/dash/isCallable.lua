--[[
	Returns `true` if the value can be called i.e. you can write `value(...)`.
]]
local function isCallable(value: any): boolean
	return type(value) == "function" or
		(type(value) == "table" and getmetatable(value) and getmetatable(value).__call ~= nil) or false
end

return isCallable