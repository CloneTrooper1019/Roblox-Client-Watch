--[[
	Returns a table of unique values keyed on name for each component.
]]

local function createTableCache(tableName)
	local UniqueTable = {}

	UniqueTable.__tostring = function(t)
		return ("%s(%s)"):format(tableName, t.name)
	end

	function UniqueTable:add(name)
		assert(type(name) == "string", ("%s must be created using a string name!"):format(tableName))

		if rawget(UniqueTable, name) then
			return rawget(UniqueTable, name)
		else
			local result = setmetatable({
				name = name
			}, UniqueTable)

			UniqueTable[name] = result

			return result
		end
	end

	return UniqueTable
end

return createTableCache