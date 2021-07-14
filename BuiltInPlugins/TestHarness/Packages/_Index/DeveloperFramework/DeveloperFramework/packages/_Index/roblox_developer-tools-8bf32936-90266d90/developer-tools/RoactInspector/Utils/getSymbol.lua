local foundSymbols = {}

local function getSymbol(object, name)
	if foundSymbols[name] then
		return object[foundSymbols[name]]
	end
	for key, value in pairs(object) do
		if tostring(key) == "Symbol(" .. name .. ")" then
			foundSymbols[name] = key
			return value
		end
	end
end

return getSymbol