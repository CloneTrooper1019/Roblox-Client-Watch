--[[
	Output a new Map from merging all the keys in the Map arguments in left-to-right order.

	The None symbol can be used to remove existing elements.

	@param ... any number of tables
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assign = require(Dash.assign)

-- TODO Luau: Support typing varargs
-- TODO Luau: Support function generics
local function join(...): Types.Map<any, any>
	return assign({}, ...)
end

return join