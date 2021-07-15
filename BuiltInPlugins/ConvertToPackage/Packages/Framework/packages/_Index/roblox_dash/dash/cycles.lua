--[[
	Get information about the number of times references to the same table values appear in a data structure.

	Operates on cyclic structures, and returns a Cycles object for a given _value_ by walking it recursively.
]]
local Dash = script.Parent
local Types = require(Dash.Types)
local includes = require(Dash.includes)
local join = require(Dash.join)
local keys = require(Dash.keys)

local sort = table.sort

export type Cycles = {
	-- A set of tables which were visited recursively
	visited: Types.Set<Types.Table>,
	-- A map from table to unique index in visit order
	refs: Types.Map<Types.Table, number>,
	-- The number to use for the next unique table visited
	nextRef: number,
	-- An array of keys which should not be visited
	omit: Types.Array<any>,
}

local function getDefaultCycles(): Cycles
	return {
		visited = {},
		refs = {},
		nextRef = 1,
		omit = {},
	}
end

-- TODO Luau: Improve type inference to a point that this definition does not produce so many type errors
-- TYPED: local function cycles(value: any, depth: number?, initialCycles: Cycles?): Cycles
local function cycles(input: any, depth: number?, initialCycles: any): Cycles?
	if depth == -1 then
		return initialCycles
	end

	if typeof(input) == "table" then
		local childCycles = initialCycles or getDefaultCycles()

		if childCycles.visited[input] then
			-- We have already visited the table, so check if it has a reference
			if not childCycles.refs[input] then
				-- If not, create one as it is present at least twice
				childCycles.refs[input] = childCycles.nextRef
				childCycles.nextRef += 1
			end
			return nil
		else
			-- We haven't yet visited the table, so recurse
			childCycles.visited[input] = true
			-- Visit in order to preserve reference consistency
			local inputKeys = keys(input)
			sort(inputKeys, function(left, right)
				if typeof(left) == "number" and typeof(right) == "number" then
					return left < right
				else
					return tostring(left) < tostring(right)
				end
			end)
			for _, key in ipairs(inputKeys) do
				local value = input[key]
				if includes(childCycles.omit, key) then
					-- Don't visit omitted keys
					continue
				end
				-- TODO Luau: support type narrowring with "and"
				-- TYPED: cycles(key, depth and depth - 1 or nil, childCycles)
				-- TYPED: cycles(value, depth and depth - 1 or nil, childCycles)
				-- Recurse through both the keys and values of the table
				if depth then
					cycles(key, depth - 1, childCycles)
					cycles(value, depth - 1, childCycles)
				else
					cycles(key, nil, childCycles)
					cycles(value, nil, childCycles)
				end
			end
		end
		return childCycles
	else
		-- Non-tables do not have cycles
		return nil
	end
end

return cycles