--[[
	Iterates through the elements of the _input_ Array in order 1..n.

	Calls the _handler_ for each entry and returns the first non-nil value returned by the handler.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
export type MapHandler = (any, number) -> any

local function mapFirst(input: Types.Array<any>, handler: MapHandler)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.mapFirst with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.mapFirst with argument #2 of type {left:?} not {right:?}]])
	for index, child in ipairs(input) do
		local output = handler(child, index)
		if output ~= nil then
			return output
		end
	end
end
return mapFirst