local Source = script.Parent.Parent.Parent
local Packages = Source.Parent
local getSymbol = require(Source.RoactInspector.Utils.getSymbol)

local Dash = require(Packages.Dash)
local startsWith = Dash.startsWith

local function getChildAtKey(object, key)
	if object == nil then
		return nil
	end
	local child = object[key]
	if child == nil and typeof(key) == "number" then
		-- Try a string representation of a numeric key if need be
		child = object[tostring(key)]
	end
	if child == nil and typeof(key) == "string" and startsWith(key, "Symbol(") then
		-- Strip Symbol() from the key
		local symbolName = key:sub(8, -2)
		child = getSymbol(object, symbolName)
	end
	return child
end

return getChildAtKey