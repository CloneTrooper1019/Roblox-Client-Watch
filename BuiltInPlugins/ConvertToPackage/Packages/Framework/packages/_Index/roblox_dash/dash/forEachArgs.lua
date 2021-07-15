--[[
	Iterates through the tail arguments in order, including nil values up to the argument list length.
	Calls the _handler_ for each entry.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

export type ForEachArgsHandler<Value> = (Value, number) -> ()
-- TODO Luau: Support function generics
-- TODO Luau: Support vararg types
--local function forEachArgs<Value>(handler: ForEachArgsHandler<Value>, ...: Types.Args<Value>)

local function forEachArgs(handler: Types.AnyFunction, ...)
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.forEachArgs with argument #1 of type {left:?} not {right:?}]])
	for index = 1, select('#', ...) do
		handler(select(index, ...), index)
	end
end
return forEachArgs