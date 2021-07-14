--[[
	Adds new elements to the _target_ Array from subsequent Array arguments in left-to-right order.
	
	Arguments which are `nil` or None are skipped.

	@mutable target
]]

local Dash = script.Parent
local None = require(Dash.None)
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)
local forEachArgs = require(Dash.forEachArgs)
local forEach = require(Dash.forEach)
local insert = table.insert

-- TODO Luau: Add varags typings
local function append(target: Types.Array<any>, ...): Types.Array<any>
	assertEqual(typeof(target), "table", [[Attempted to call Dash.append with argument #1 of type {left:?} not {right:?}]])
	forEachArgs(function(list: Types.Table?)
		if list == None or list == nil then
			return
		end
		forEach(list, function(value: any)
			insert(target, value)
		end)
	end, ...)
	return target
end

return append