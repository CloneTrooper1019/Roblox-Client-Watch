local Plugin = script.Parent.Parent.Parent.Parent

local SetAssetConfigManageableGroups = require(Plugin.Core.Actions.SetAssetConfigManageableGroups)
local NetworkError = require(Plugin.Core.Actions.NetworkError)

return function(networkInterface)
	return function(store)
		return networkInterface:getManageableGroups():andThen(function(result)
			local groups = result.responseBody.data
			store:dispatch(SetAssetConfigManageableGroups(groups))
		end, function(result)
			store:dispatch(NetworkError(result))
		end)
	end
end
