--[[
	Makes a string of `length` from `input` by repeating characters from `suffix` at the end of the string.

	By default, suffix is " ".

	@example rightPad("toast", 6) --> "toast "
	@example rightPad("2", 2, "!") --> "2!"
	@example rightPad("toast", 10, ":)") --> "toast:):):"
]]
local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local function rightPad(input: string, length: number, suffix: string?): string
	assertEqual(typeof(input), "string", [[Attempted to call Dash.rightPad with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(length), "number", [[Attempted to call Dash.rightPad with argument #2 of type {left:?} not {right:?}]])

	local definedSuffix = suffix or " "
	assertEqual(typeof(definedSuffix), "string", [[Attempted to call Dash.rightPad with argument #3 of type {left:?} not {right:?}]])

	local padLength = length - input:len()
	local remainder = padLength % definedSuffix:len()
	local repetitions = (padLength - remainder) / definedSuffix:len()
	return input .. string.rep(suffix or " ", repetitions) .. definedSuffix:sub(1, remainder)
end

return rightPad