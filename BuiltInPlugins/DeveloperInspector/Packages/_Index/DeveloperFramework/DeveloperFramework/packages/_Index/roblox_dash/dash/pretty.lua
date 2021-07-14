--[[
	Return a pretty string serialization of _object_.

	This implementation deals with cycles in tables and can neatly display metatables.

	Optionally use an indented multiline string, limit the depth of tables, omit or pick keys.
]]
local Dash = script.Parent
local Types = require(Dash.Types)

local append = require(Dash.append)
local assign = require(Dash.assign)
local cycles = require(Dash.cycles)
local includes = require(Dash.includes)
local join = require(Dash.join)
local map = require(Dash.map)
local keys = require(Dash.keys)
local slice = require(Dash.slice)

local concat = table.concat
local insert = table.insert
local sort = table.sort

export type PrettyOptions = {
	-- The maximum depth of ancestors of a table to display (default = 2)
	depth: number?,
	-- An array of keys which should not be visited
	omit: Types.Array<any>?,
	-- Whether to use multiple lines (default = false)
	multiline: boolean?,
	-- Whether to show the length of any array in front of its content
	arrayLength: boolean?,
	-- The maximum length of a line (default = 80)
	maxLineLength: number?,
	-- Whether to drop the quotation marks around strings. By default, this is true for table keys
	noQuotes: boolean?,
	-- The indent string to use (default = "\t")
	indent: string?,
	-- A set of tables which have already been visited and should be referred to by reference
	visited: Types.Set<Types.Table>?,
	-- A cycles object returned from `cycles` to aid reference display
	cycles: cycles.Cycles?,
}

local function indentLines(lines: Types.Array<string>, indent: string)
	return map(lines, function(line: string)
		return indent .. line
	end)
end

local pretty


-- TODO Luau: Improve type inference to a point that this definition does not produce so many type errors
-- local function prettyLines(object: any, options: PrettyOptions?): Types.Array<string>
local function prettyLines(object: any, options: any): Types.Array<string>
	options = options or {}
	if type(object) == "table" then
		-- A table needs to be serialized recusively
		-- Construct the options for recursive calls for the table values
		local valueOptions = assign({
			visited = {},
			indent = "\t",
			depth = 2
		}, options, {
			-- Depth is reduced until we shouldn't recurse any more
			depth = options.depth and options.depth - 1 or nil,
			cycles = options.cycles or cycles(object, options.depth, {
				visited = {},
				refs = {},
				nextRef = 0,
				depth = options.depth,
				omit = options.omit or {}
			})
		})
		if valueOptions.depth == -1 then
			-- Indicate there is more information available beneath the maximum depth
			return {"..."}
		end
		if valueOptions.visited[object] then
			-- Indicate this table has been printed already, so print a ref number instead of
			-- printing it multiple times
			return {"&" .. valueOptions.cycles.refs[object]}
		end
		
		valueOptions.visited[object] = true

		local multiline = valueOptions.multiline
		local comma = multiline and "," or ", "

		-- If the table appears multiple times in the output, mark it with a ref prefix so it can
		-- be identified if it crops up later on
		local ref = valueOptions.cycles.refs[object]
		local refTag = ref and ("<%s>"):format(ref) or ""
		local lines = {refTag .. "{"}

		-- Build the options for the recursive call for the table keys
		local keyOptions = join(valueOptions, {
			noQuotes = true,
			multiline = false
		})

		-- Compact numeric keys into a simpler array style
		local maxConsecutiveIndex = 0
		local first = true
		for index, value in ipairs(object) do
			if valueOptions.omit and includes(valueOptions.omit, index) then
				-- Don't include keys which are omitted
				continue
			end
			if first then
				first = false
			else
				lines[#lines] = lines[#lines] .. comma
			end
			if valueOptions.multiline then
				local indendedValue = indentLines(prettyLines(value, valueOptions), valueOptions.indent)
				append(lines, indendedValue)
			else
				lines[#lines] = lines[#lines] .. pretty(value, valueOptions)
			end
			maxConsecutiveIndex = index
		end
		if #object > 0 and valueOptions.arrayLength then
			lines[1] = ("#%d %s"):format(#object, lines[1])
		end
		-- Ensure keys are printed in order to guarantee consistency
		local objectKeys = keys(object)
		sort(objectKeys, function(left, right)
			if typeof(left) == "number" and typeof(right) == "number" then
				return left < right
			else
				return tostring(left) < tostring(right)
			end
		end)
		for _, key in ipairs(objectKeys) do
			local value = object[key]
			-- We printed a key if it's an index e.g. an integer in the range 1..n.
			if typeof(key) == "number" and key % 1 == 0 and key >= 1 and key <= maxConsecutiveIndex then
				continue
			end
			if valueOptions.omit and includes(valueOptions.omit, key) then
				-- Don't include keys which are omitted
				continue
			end
			if first then
				first = false
			else
				lines[#lines] = lines[#lines] .. comma
			end
			if valueOptions.multiline then
				local keyLines = prettyLines(key, keyOptions)
				local indentedKey = indentLines(keyLines, valueOptions.indent)
				local valueLines = prettyLines(value, valueOptions)
				local valueTail = slice(valueLines, 2)
				local indendedValueTail = indentLines(valueTail, valueOptions.indent)
				-- The last line of the key and first line of the value are concatenated together
				indentedKey[#indentedKey] = ("%s = %s"):format(indentedKey[#indentedKey], valueLines[1])
				append(lines, indentedKey)
				append(lines, indendedValueTail)
			else
				lines[#lines] = ("%s%s = %s"):format(lines[#lines], pretty(key, keyOptions), pretty(value, valueOptions))
			end
		end
		if valueOptions.multiline then
			if first then
				-- An empty table is just represented as {}
				lines[#lines] = lines[#lines] .. "}"
			else
				insert(lines, "}")
			end
		else
			lines[#lines] = ("%s}"):format(lines[#lines])
		end
		return lines
	elseif type(object) == "string" and not options.noQuotes then
		return {('"%s"'):format(object)}
	else
		return {tostring(object)}
	end
end

-- TODO Luau: Improve type inference to a point that this definition does not produce so many type errors
-- pretty = function(object: any, options: PrettyOptions?): string
pretty = function(object: any, options: any): string
	return concat(prettyLines(object, options), "\n")
end

return pretty