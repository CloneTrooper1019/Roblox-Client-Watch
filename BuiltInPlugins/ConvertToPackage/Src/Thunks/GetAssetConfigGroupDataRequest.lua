local Plugin = script.Parent.Parent.Parent

local HttpService = game:GetService("HttpService")

local Actions = Plugin.Src.Actions
local SetAssetGroupData = require(Actions.SetAssetGroupData)
local sendResultToKibana = require(Plugin.Packages.Framework.Util.sendResultToKibana)

local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

return function(networkInterface, groupId)
	return function(store)
		return networkInterface:getAssetGroupData(groupId):andThen(
			function(result)
				local responseJson = result.responseBody
				-- This will require we have HttpService
				local response = HttpService:JSONDecode(responseJson)
				if FFlagNewPackageAnalyticsWithRefactor2 then
					sendResultToKibana(result)
				end
				store:dispatch(SetAssetGroupData(response.data))
			end,
			function(result)
				-- TODO DEVTOOLS-2831
				-- Implement the error function.
			end)
	end
end
