--[[
	Collect returns a new Table derived from _input_ by iterating through its pairs and calling
	the handler on each `(key, child)` tuple. 

	The handler should return a new `(newKey, value)` tuple to be inserted into the returned Table,
	or `nil` if no value should be added.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local iterator = require(Dash.iterator)

-- TODO Luau: support generic function definitions
export type CollectHandler = () -> (any, any)

local function collect(input: Types.Table, handler: CollectHandler): Types.Map<any, any>
	assertEqual(typeof(input), "table", [[Attempted to call Dash.collect with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(handler), "function", [[Attempted to call Dash.collect with argument #2 of type {left:?} not {right:?}]])
	local result = {}
	for key, child in iterator(input) do
		local outputKey, outputValue = handler(key, child)
		if outputKey ~= nil then
			result[outputKey] = outputValue
		end
	end
	return result
end
return collect