--[[
	Iterates through the elements of the _input_ Table in no particular order.

	Calls the _handler_ for each entry and returns `true` if the handler returns truthy for any
	element which it is called with.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
export type SomeHandler = (any, any) -> boolean

local function some(input: Types.Map<any, any>, handler: SomeHandler?): boolean
	assertEqual(typeof(input), "table", [[Attempted to call Dash.some with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.some with argument #2 of type {left:?} not {right:?}]])
	for key, child in pairs(input) do
		if handler(child, key) then
			return true
		end
	end
	return false
end
return some