--[[
	Checks if _input_ starts with the string _start_.
	@example startsWith("Fun Roblox Games", "Fun") --> true
	@example startsWith("Chess", "Fun") --> false
]]
local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local function startsWith(input: string, prefix: string): boolean
	assertEqual(typeof(input), "string", [[Attempted to call Dash.startsWith with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(prefix), "string", [[Attempted to call Dash.startsWith with argument #2 of type {left:?} not {right:?}]])
	return input:sub(1, prefix:len()) == prefix
end

return startsWith