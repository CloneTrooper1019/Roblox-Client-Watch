--[[
	Pick entries in the _input_ Table which should remain in the output by calling the handler on
	each `(child, index)` tuple.

	The handler should return truthy to preserve the value in the resulting Table.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

-- TODO Luau: support generic function definitions
export type PickHandler = (any, any) -> boolean

local function pick(input: Types.Map<any, any>, handler: PickHandler): Types.Map<any, any>
	assertEqual(typeof(input), "table", [[Attempted to call Dash.pick with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.pick with argument #2 of type {left:?} not {right:?}]])
	local result = {}
	for key, child in iterator(input) do
		if handler(child, key) then
			result[key] = child
		end
	end
	return result
end
return pick