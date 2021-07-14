local shallowEqual = require(script.Parent.Parent.shallowEqual)
local toString = require(script.Parent.Parent.toString)

local function expectTable(tab)
	return {
		toEqual = function(value)
			assert(
				shallowEqual(tab, value),
				string.format("expected: %s\ninstead got: %s", toString(value), toString(tab))
			)
		end,
	}
end

return expectTable