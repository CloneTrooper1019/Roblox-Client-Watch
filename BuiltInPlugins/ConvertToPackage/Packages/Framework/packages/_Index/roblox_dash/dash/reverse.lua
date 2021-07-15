--[[
	Reverse the order of the elements in the _input_ Array.
]]

local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

local insert = table.insert

local function reverse(input: Types.Array<any>): Types.Array<any>
	assertEqual(typeof(input), "table", [[Attempted to call Dash.reverse with argument #1 of type {left:?} not {right:?}]])
	local output = {}
	for i = #input, 1, -1 do
		insert(output, input[i])
	end
	return output
end
return reverse