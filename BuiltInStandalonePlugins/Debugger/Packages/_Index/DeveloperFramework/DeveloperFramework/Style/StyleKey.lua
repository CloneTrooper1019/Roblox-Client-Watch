--[[
	Returns a table of unique values which are given a StyleKey metatable to differentiate it as a StyleKey value.
	The Stylizer refers to StyleKey and replaces them with the correct color value.
]]

local Framework = script.Parent.Parent
local tableCache = require(Framework.Util.tableCache)

local StyleKey = tableCache("StyleKey")

setmetatable(StyleKey, {
	__index = function(t, name)
		local newStyleKey = StyleKey:add(name)
		t[name] = newStyleKey
		return newStyleKey
	end
})

return StyleKey