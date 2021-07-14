--[[
	Returns the index of the first element in the _input_ Array that the handler returns `true` for,
	when passed the `(child, key)` entry.

	Returns nil if no entires satisfy the condition.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: support generic function definitions
export type FindHandler = (any, any) -> boolean

local function findIndex(input: Types.Array<any>, handler: FindHandler)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.findIndex with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.findIndex with argument #2 of type {left:?} not {right:?}]])
	for key, child in ipairs(input) do
		if handler(child, key) then
			return key
		end
	end
end
return findIndex