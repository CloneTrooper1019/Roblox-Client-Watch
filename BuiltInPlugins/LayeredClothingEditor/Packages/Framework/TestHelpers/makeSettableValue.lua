local DevFrameworkRoot = script.Parent.Parent
local Signal = require(DevFrameworkRoot.Util.Signal)

--[[
Wrapper to encapsulate a value with get/set methods and a changed signal
]]
return function(initialValue)
	local value = initialValue
	local changed = Signal.new()

	return {
		get = function()
			return value
		end,
		set = function(newValue)
			value = newValue
			changed:Fire()
		end,
		changed = changed,
	}
end
