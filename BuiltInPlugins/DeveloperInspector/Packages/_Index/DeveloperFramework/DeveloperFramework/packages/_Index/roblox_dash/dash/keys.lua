--[[
	Returns an Array of the keys in the _input_ Table.

	If the input is an Array, ordering is preserved.

	If the input is a Map, elements are returned in an arbitrary order.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

local insert = table.insert

-- TODO Luau: Support generic functions
local function keys(input: Types.Table): Types.Array<any>
	assertEqual(typeof(input), "table", [[Attempted to call Dash.keys with argument #1 of type {left:?} not {right:?}]])
	local result = {}
	for key, _ in iterator(input) do
		insert(result, key)
	end
	return result
end
return keys