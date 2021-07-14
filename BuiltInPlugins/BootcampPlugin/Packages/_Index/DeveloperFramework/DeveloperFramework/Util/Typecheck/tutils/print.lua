return function(print)
	local function makeKeyString(key)
		if type(key) == "string" then
			return string.format("%s", key)
		else
			return string.format("[%s]", tostring(key))
		end
	end

	local function makeValueString(value)
		local valueType = type(value)
		if valueType == "string" then
			return string.format("%q", value)
		elseif valueType == "function" or valueType == "table" then
			return string.format("<%s>", tostring(value))
		else
			return string.format("%s", tostring(value))
		end
	end

	local function printKeypair(key, value, indentStr, comment)
		local keyString = makeKeyString(key)
		local valueString = makeValueString(value)

		local commentStr = comment and string.format(" -- %s", comment) or ""
		print(string.format("%s%s = %s,%s", indentStr, keyString, valueString, commentStr))
	end

	--[[
		For debugging. Prints the table on multiple lines to overcome log-line length
		limitations which are otherwise necessary for performance. Use sparingly.
	]]
	return function(t, indent)
		indent = indent or '  '

		if type(t) ~= "table" then
			error("tutils.Print must be passed a table", 2)
		end

		-- For cycle detection
		local printedTables = {}

		local function recurse(subTable, tableKey, level)
			-- Prevent cycles by keeping track of what tables we have printed
			printedTables[subTable] = true

			local indentStr = string.rep(indent, level)
			local valueIndentStr = string.rep(indent, level + 1)

			if tableKey then
				print(string.format("%s%s = %s {", indentStr, makeKeyString(tableKey), makeValueString(subTable)))
			else
				print(string.format("%s%s {", indentStr, makeValueString(subTable)))
			end

			for key, value in pairs(subTable) do
				if type(value) == "table" then
					if printedTables[value] then
						printKeypair(key, value, valueIndentStr, "Possible cycle")
					else
						recurse(value, key, level + 1)
					end
				else
					printKeypair(key, value, valueIndentStr)
				end
			end

			print(string.format("%s}%s", indentStr, (level > 0 and "," or "")))
		end

		recurse(t, nil, 0)
	end
end