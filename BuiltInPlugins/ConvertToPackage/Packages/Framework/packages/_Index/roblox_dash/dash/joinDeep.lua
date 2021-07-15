--[[
	Creates a shallow clone of the _source_ Map, and copies the values from the _delta_ Map
	by key, like the join utility.
	
	However, if any of the values are tables themselves, the joinDeep function is called
	recursively to produce a new table at the specified key.

	The purpose of this function is to merge nested immutable data using as few table
	creation operations as possible, making it appropriate for updating state in a reducer.

	The None symbol can be used to remove an existing value.
]]
local Dash = script.Parent
local None = require(Dash.None)
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local forEach = require(Dash.forEach)
local copy = require(Dash.copy)

-- TODO Luau: Support typing varargs
-- TODO Luau: Support function generics
local function joinDeep(source: Types.Table, delta: Types.Table): Types.Table
	assertEqual(typeof(source), "table", [[Attempted to call Dash.joinDeep with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(delta), "table", [[Attempted to call Dash.joinDeep with argument #2 of type {left:?} not {right:?}]])
	local result = copy(source)
	-- Iterate through each key of the input and assign to target at the same key
	forEach(delta, function(value, key)
		if typeof(source[key]) == "table" and typeof(value) == "table" then
			-- Only merge tables
			result[key] = joinDeep(source[key], value)
		elseif value == None then
			-- Remove none values
			result[key] = nil
		else
			result[key] = value
		end
	end)
	return result
end

return joinDeep