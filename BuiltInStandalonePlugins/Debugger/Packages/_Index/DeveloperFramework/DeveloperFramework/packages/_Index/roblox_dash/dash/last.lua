--[[
	Returns the last element in the _input_ Array that the handler returns `true` for, when
	passed the `(child, index)` entry.

	Returns nil if no entires satisfy the condition.

	If handler is not defined, the function simply returns the last element of the Array.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: support generic function definitions
export type FindHandler = (any, any) -> boolean

local function last(input: Types.Array<any>, handler: FindHandler?)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.last with argument #1 of type {left:?} not {right:?}]])
	for index = #input, 1, -1 do
		local child = input[index]
		if not handler then
			return child
		end
		if handler(child, index) then
			return child
		end
	end
end

return last