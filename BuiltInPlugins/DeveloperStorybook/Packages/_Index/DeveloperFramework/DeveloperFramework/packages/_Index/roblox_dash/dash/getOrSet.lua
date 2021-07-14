--[[
	Returns a value of the _input_ Table at the _key_ provided.
	
	If the key is missing, the value is acquired from the _getValue_ handler,
	added to the _input_ Table and returned.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local Error = require(Dash.Error)
local assertEqual = require(Dash.assertEqual)
local format = require(Dash.format)

-- TODO Luau: Support generic functions
export type GetValueHandler = (any) -> any

local function getOrSet(input: Types.Table, key: any, getValue: GetValueHandler)
	assertEqual(typeof(input), "table", [[Attempted to call Dash.getOrSet with argument #1 of type {left:?} not {right:?}]])
	assertEqual(key == nil, false, [[Attempted to call Dash.getOrSet with a nil key argument]])
	assertEqual(typeof(getValue), "function", [[Attempted to call Dash.getOrSet with argument #3 of type {left:?} not {right:?}]])
	if input[key] == nil then
		input[key] = getValue(input, key)
	end
	return input[key]
end
return getOrSet