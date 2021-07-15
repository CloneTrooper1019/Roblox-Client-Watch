local Plugin = script.Parent.Parent.Parent

local SetMyGroups = require(Plugin.Src.Actions.SetMyGroups)
local NetworkError = require(Plugin.Src.Actions.NetworkError)
local sendResultToKibana = require(Plugin.Packages.Framework.Util.sendResultToKibana)

local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

return function(networkInterface)
	return function(store)
		return networkInterface:getMyGroups():andThen(function(result)
			local response = result.responseBody
			if FFlagNewPackageAnalyticsWithRefactor2 then
				sendResultToKibana(result)
			end
			store:dispatch(SetMyGroups(response.data))
		end, function(result)
			store:dispatch(NetworkError(result))
		end)
	end
end