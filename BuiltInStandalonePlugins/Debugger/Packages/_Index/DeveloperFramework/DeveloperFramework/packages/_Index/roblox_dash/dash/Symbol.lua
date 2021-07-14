--[[
	Create a symbol with a specified name. Upper snake-case is recommended as the symbol is a
	constant, unless you are linking the symbol conceptually to a different string.

	Symbols are useful when you want a value that isn't equal to any other type, for example if you
	want to store a unique property on an object that won't be accidentally accessed with a simple
	string lookup.

	@example
	local CHEESE = Symbol.new("CHEESE")
	local FAKE_CHEESE = Symbol.new("CHEESE")
	print(CHEESE == CHEESE) --> true
	print(CHEESE == FAKE_CHEESE) --> false
	print(tostring(CHEESE)) --> "Symbol.new(CHEESE)"
]]
local Dash = script.Parent
local class = require(Dash.class)

local Symbol = class("Symbol", function(name: string)
	return {
		name = name
	}
end)

function Symbol:toString(): string
	return ("Symbol(%s)"):format(self.name)
end

-- TODO Luau: Define class types automatically
export type Symbol = typeof(Symbol.new(""))

return Symbol