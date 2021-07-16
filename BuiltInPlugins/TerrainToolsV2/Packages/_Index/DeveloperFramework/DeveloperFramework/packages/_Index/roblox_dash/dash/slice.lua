--[[
	Return a portion of the _input_ Array starting with the element at the _left_ index and ending
	with the element at the _right_ index (i.e. an inclusive range)

	If _left_ is not defined, it defaults to 1.
	If _right_ is not defined, it defaults to the length of the array (i.e. the last element)

	If _left_ is `-n`, the slice starts with the element `n` places from the last one.
	If _right_ is `-n`, the slice ends with the element `n` places from the last one.

	An empty array is returned if the slice has no or negative length.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

local insert = table.insert

local function slice(input: Types.Array<any>, left: number?, right: number?)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.slice with argument #1 of type {left:?} not {right:?}]])
	local output = {}

	-- Default values
	left = left or 1
	right = right or #input
	assertEqual(typeof(left), "number", [[Attempted to call Dash.slice with argument #2 of type {left:?} not {right:?}]])
	assertEqual(typeof(right), "number", [[Attempted to call Dash.slice with argument #3 of type {left:?} not {right:?}]])

	if left < 0 then
		left = #input + left
	end
	if right and right < 0 then
		right = #input + right
	end
	for i = left, right do
		insert(output, input[i])
	end
	return output
end

return slice