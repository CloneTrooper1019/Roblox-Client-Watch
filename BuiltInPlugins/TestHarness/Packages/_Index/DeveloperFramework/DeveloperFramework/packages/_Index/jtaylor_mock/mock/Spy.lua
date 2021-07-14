-- Create a wrapper around a function to capture what arguments it was called
-- with.

local symbols = require(script.Parent.symbols)

local Spy = {}
Spy.__index = Spy

local spyLookup = {}
setmetatable(spyLookup, {__mode = "kv"})

function Spy.new(inner)
	local spy = {
		[symbols.Calls] = {}
	}
	setmetatable(spy, Spy)

	local wrapper = function(...)
		local call = {
			args = table.pack(...),
			result = table.pack(inner(...)),
		}
		table.insert(spy[symbols.Calls], call)
		return table.unpack(call.result)
	end

	spy.inner = wrapper
	spyLookup[wrapper] = spy

	return spy, wrapper
end

function Spy.lookup(wrapper)
	return spyLookup[wrapper]
end

return Spy