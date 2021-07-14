--[[
	Returns an element in the _input_ Table that the handler returns `true` for, when passed the
	`(child, key)` entry.

	Returns nil if no entires satisfy the condition.

	For an Array, this first matching element is returned.
		
	For a Map, an arbitrary matching element is returned if it exists.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

-- TODO Luau: support generic function definitions
export type FindHandler = (any, any) -> boolean

local function find(input: Types.Table, handler: FindHandler)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.find with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.find with argument #2 of type {left:?} not {right:?}]])
	for key, child in iterator(input) do
		if handler(child, key) then
			return child
		end
	end
end
return find