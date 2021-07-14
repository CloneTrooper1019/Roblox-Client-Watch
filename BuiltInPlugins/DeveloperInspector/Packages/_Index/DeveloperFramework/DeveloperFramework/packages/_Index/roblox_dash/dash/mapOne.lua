--[[
	Iterates through the elements of the _input_ Table in no particular order.

	Calls the _handler_ for each entry and returns the first non-nil value returned by the handler.

	If _handler_ is nil, the first value visited is returned.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
export type MapHandler = (any, number) -> any

local function mapOne(input: Types.Table, handler: MapHandler?)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.mapOne with argument #1 of type {left:?} not {right:?}]])
	for key, child in pairs(input) do
		local output
		if handler then
			output = handler(child, key)
		else
			output = child
		end
		if output ~= nil then
			return output
		end
	end
end
return mapOne