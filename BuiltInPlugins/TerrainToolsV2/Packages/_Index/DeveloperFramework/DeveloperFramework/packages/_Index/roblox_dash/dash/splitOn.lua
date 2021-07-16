--[[
	Splits _input_ into parts based on a _pattern_ delimiter and returns a Table of the parts,
	followed by a Table of the matched delimiters.
]]
local Dash = script.Parent
local assertEqual = require(Dash.assertEqual)

local insert = table.insert

local function splitOn(input: string, pattern: string): Types.Array<string>
	assertEqual(typeof(input), "string", [[Attempted to call Dash.splitOn with argument #1 of type {left:?} not {right:?}]])
	assertEqual(typeof(pattern), "string", [[Attempted to call Dash.splitOn with argument #2 of type {left:?} not {right:?}]])
	local parts = {}
	local delimiters = {}
	local from = 1
	if not pattern then
		for i = 1, #input do
			insert(parts, input:sub(i, i))
		end
		return parts
	end
	local delimiterStart, delimiterEnd = input:find(pattern, from)
	while delimiterStart do
		insert(delimiters, input:sub(delimiterStart, delimiterEnd))
		insert(parts, input:sub(from, delimiterStart - 1))
		from = delimiterEnd + 1
		delimiterStart, delimiterEnd = input:find(pattern, from)
	end
	insert(parts, input:sub(from))
	return parts, delimiters
end

return splitOn