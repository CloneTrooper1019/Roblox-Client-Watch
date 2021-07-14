--[[
	Iterates through the elements of the _input_ Table.

	If the table is an Array, it iterates in order 1..n.

	If the table is a Map, the keys are visited in an arbitrary order.

	Calls the _handler_ for each entry.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

export type ForEachHandler<Value> = (Value, number) -> ()
-- TODO Luau: Support function generics
--local function forEach<Value>(input: Types.Array<Value>, handler: ForEachHandler<Value>)
local function forEach(input: Types.Table, handler: Types.AnyFunction)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.forEach with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.forEach with argument #2 of type {left:?} not {right:?}]])
	for key, value in iterator(input) do
		handler(value, key)
	end
end
return forEach