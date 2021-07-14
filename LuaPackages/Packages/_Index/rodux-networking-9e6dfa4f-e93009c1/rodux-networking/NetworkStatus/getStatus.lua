local root = script.Parent
local getDeepValue = require(root.getDeepValue)
local EnumNetworkStatus = require(root.EnumNetworkStatus)

return function(options)
	local keyPath = options.keyPath

	return function(state, fetchStatusKey)
		assert(typeof(state) == "table")
		assert(typeof(fetchStatusKey) == "string")
		assert(#fetchStatusKey > 0)
		local reducerValue = getDeepValue(state, keyPath)
		assert(reducerValue, string.format(
			"Reducer not found for keyPath: %s. Did you forget to call `installReducer`?",
			keyPath
		))

		return reducerValue[fetchStatusKey] or EnumNetworkStatus.NotStarted
	end
end
