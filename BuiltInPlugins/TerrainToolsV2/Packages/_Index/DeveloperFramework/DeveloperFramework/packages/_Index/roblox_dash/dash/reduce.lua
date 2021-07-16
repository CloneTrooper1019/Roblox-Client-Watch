--[[
	Iterate through the elements of the _input_ Array in order 1..n.

	Call the _handler_ for each element, passing the return of the previous call as the first argument.
	
	The _initial_ value is passed into the first call, and the final value returned by the function.
]]

local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
export type ReduceHandler = (any, any, any) -> any

local function reduce(input: Types.Array<any>, handler: ReduceHandler, initial: any)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.reduce with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.reduce with argument #2 of type {left:?} not {right:?}]])
	local result = initial
	for i = 1, #input do
		result = handler(result, input[i], i)
	end
	return result
end

return reduce