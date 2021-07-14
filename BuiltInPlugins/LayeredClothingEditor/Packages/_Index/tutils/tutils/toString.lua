local checkListConsistency = require(script.Parent.checkListConsistency)

--[[
	Serializes the given table to a reasonable string that might even interpret as lua.
]]
local function recursiveToString(t, indent)
	indent = indent or ''

	if type(t) == 'table' then
		local result = ""
		if not checkListConsistency(t) then
			result = result .. "-- WARNING: this table fails the list consistency test\n"
		end
		result = result .. "{\n"
		for k,v in pairs(t) do
			if type(k) == 'string' then
				result = result
					.. "  "
					.. indent
					.. tostring(k)
					.. " = "
					.. recursiveToString(v, "  "..indent)
					..";\n"
			end
			if type(k) == 'number' then
				result = result .. "  " .. indent .. recursiveToString(v, "  "..indent)..",\n"
			end
		end
		result = result .. indent .. "}"
		return result
	else
		return tostring(t)
	end
end

return recursiveToString