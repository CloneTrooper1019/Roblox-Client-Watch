--[[
	Iterates through the elements of the _input_ Array in reverse in order n..1.

	Calls the _handler_ for each entry and returns the first non-nil value returned by the handler.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
export type MapHandler = (any, number) -> any

local function mapLast(input: Types.Array<any>, handler: MapHandler)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.mapLast with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.mapLast with argument #2 of type {left:?} not {right:?}]])
	for key = #input, 1, -1 do
		local child = input[key]
		local output = handler(child, key)
		if output ~= nil then
			return output
		end
	end
end
return mapLast