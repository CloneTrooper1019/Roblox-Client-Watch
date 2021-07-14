local foundSymbols = {}

--[[
	Return a value from the _object_ at a key which is a symbol called _name_, if one exists.
]]
local function getSymbol(object, name: string)
	-- If the symbol is already cached
	if foundSymbols[name] and object[foundSymbols[name]] ~= nil then
		return object[foundSymbols[name]]
	end
	-- Otherwise, iterate through the object keys and check if any are symbols of the correct name.
	for key, value in pairs(object) do
		if tostring(key) == "Symbol(" .. name .. ")" then
			foundSymbols[name] = key
			return value
		end
	end
end

return getSymbol