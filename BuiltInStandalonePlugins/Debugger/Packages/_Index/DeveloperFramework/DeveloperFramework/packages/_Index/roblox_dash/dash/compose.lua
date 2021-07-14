--[[
	Returns a function that calls the argument functions in left-right order on an input, passing
	the return of the previous function as argument(s) to the next.
		
	@example
		local function fry(item)
			return "fried " .. item
		end
		local function cheesify(item)
			return "cheesy " .. item
		end
		local prepare = compose(fry, cheesify)
		prepare("nachos") --> "cheesy fried nachos"
]]
-- TODO Luau: Support generic functions
-- TODO Luau: Support varargs
--: <A>((...A -> ...A)[]) -> ...A -> A
local Dash = script.Parent
local identity = require(Dash.identity)

local function compose(...)
	local fnCount = select("#", ...)
	if fnCount == 0 then
		return identity
	end
	local fns = {...}
	return function(...)
		local result = {fns[1](...)}
		for i = 2, fnCount do
			result = {fns[i](unpack(result))}
		end
		return unpack(result)
	end
end

return compose