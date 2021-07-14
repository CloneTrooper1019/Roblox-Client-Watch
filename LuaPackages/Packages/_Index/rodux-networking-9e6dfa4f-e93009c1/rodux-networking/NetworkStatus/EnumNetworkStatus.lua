local EnumNetworkStatus = {}

local EnumValues = {
	NotStarted = "NotStarted",
	Fetching = "Fetching",
	Done = "Done",
	Failed = "Failed",
}

setmetatable(EnumNetworkStatus,
	{
		__newindex = function(t, key, index)
		end,
		__index = function(t, index)
			assert(EnumValues[index] ~= nil, ("EnumNetworkStatus has no value: " .. tostring(index)))
			return EnumValues[index]
		end
	})

return EnumNetworkStatus
