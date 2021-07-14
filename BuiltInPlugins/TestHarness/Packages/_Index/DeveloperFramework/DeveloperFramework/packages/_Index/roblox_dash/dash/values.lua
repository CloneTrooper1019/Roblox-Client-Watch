--[[
	Returns an Array of the values in the _input_ Map.

	If the input is an Array, ordering is preserved.

	If the input is a Map, elements are returned in an arbitrary order.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

local insert = table.insert

-- TODO Luau: Support generic functions
local function values(input: Types.Map<any, any>): Types.Array<any>
	assertEqual(typeof(input), "table", [[Attempted to call Dash.values with argument #1 of type {left:?} not {right:?}]])
	local result = {}
	for _, value in iterator(input) do
		insert(result, value)
	end
	return result
end
return values