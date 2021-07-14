--[[
	Returns `true` if the _item_ exists as a value in the _input_ table.

	A nil _item_ will always return `false`.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local assertEqual = require(Dash.assertEqual)

-- TODO Luau: Support generic functions
local function includes(input: Types.Table, item: any): boolean
	assertEqual(typeof(input), "table", [[Attempted to call Dash.includes with argument #1 of type {left:?} not {right:?}]])
	if item == nil then
		return false
	end
	for _, child in pairs(input) do
		if child == item then
			return true
		end
	end
	return false
end
return includes