--[[
	Return a new Table made from entries in the _input_ Table whose key is not in the _keys_ Array.

	If the input is an Array, ordering is preserved.

	If the input is a Map, elements are returned in an arbitrary order.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local collectSet = require(Dash.collectSet)
local forEach = require(Dash.forEach)

-- TODO Luau: Support generic functions, then substitute type signature
-- TYPED: local function omit<Key, Value>(input: Types.Map<Key, Value>, keys: Types.Array<Key>): Value
local function omit(input: Types.Table, keys: Types.Array<any>): Types.Table
	assertEqual(typeof(input), "table", [[Attempted to call Dash.omit with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(keys), "table", [[Attempted to call Dash.omit with argument #2 of type {left:?} not {right:?}]])
	local output = {}
	local keySet = collectSet(keys)
	-- TYPED: forEach(input, function(child: Value, key: Key)
	forEach(input, function(child, key)
		if not keySet[key] then
			output[key] = input[key]
		end
	end)
	return output
end

return omit