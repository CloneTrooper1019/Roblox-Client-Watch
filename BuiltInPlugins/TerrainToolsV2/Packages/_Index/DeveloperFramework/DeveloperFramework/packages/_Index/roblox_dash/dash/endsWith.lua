--[[
	Checks if _input_ ends with the string _suffix_.
	@example endsWith("Fun Roblox Games", "Games") --> true
	@example endsWith("Bad Roblox Memes", "Games") --> false
]]
local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local function endsWith(input: string, suffix: string)
	assertEqual(typeof(input), "string", [[Attempted to call Dash.endsWith with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(suffix), "string", [[Attempted to call Dash.endsWith with argument #2 of type {left:?} not {right:?}]])
	return input:sub(-suffix:len()) == suffix
end

return endsWith