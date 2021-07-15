--[[
	Remove any whitespace at the start and end of the _input_ string.
]]
local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local function trim(input: string): string
	assertEqual(typeof(input), "string", [[Attempted to call Dash.trim with argument #1 of type {left:?} not {right:?}]])
	return input:match("^%s*(.-)%s*$")
end

return trim