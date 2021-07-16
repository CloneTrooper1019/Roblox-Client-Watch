--[[
	Returns a shallow copy of the _input_ Table.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assign = require(Dash.assign)
local assertEqual = require(Dash.assertEqual)

local function copy(input: Types.Table): Types.Table
	assertEqual(typeof(input), "table", [[Attempted to call Dash.copy with argument #1 of type {left:?} not {right:?}]])
	return assign({}, input)
end
return copy