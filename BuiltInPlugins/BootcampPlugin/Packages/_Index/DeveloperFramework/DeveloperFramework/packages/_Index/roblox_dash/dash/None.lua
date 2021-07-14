--[[
	A symbol representing nothing, that can be used in place of nil as a key or value of a table,
	where nil is illegal.

	Utility functions can check for the None symbol and treat it like a nil value.

	@usage Use cases include:
	1. Creating an ordered list with undefined values in it
	2. Creating a map with a key pointing to a nil value
]]
local Symbol = require(script.Parent.Symbol)
local None = Symbol.new("None")
return None