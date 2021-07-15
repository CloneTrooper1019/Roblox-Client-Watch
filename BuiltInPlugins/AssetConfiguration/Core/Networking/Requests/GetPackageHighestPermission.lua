--[[
	A request used to determine the current user's package permission level for a list of assetIds.
	All assets in the list of assetIds must be packages.

	Then we parse the request to form a table with the following format:

	{
		id1 = action1, 
		id2 = action2,
	}

	an "id" is the assetId of that package.
	an "action" can be any of the following values "UseView,Edit,Own,Revoked".
	The current user can have the same action for multiple assetIds. e.g. I have permission to "edit"
	two differrent packages.

	Params:
		networkInterface = The NetworkInterface impl.
		assetIds = A list of asset ids, that must be all packages.
]]

local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent.Parent
local Cryo = require(Plugin.Libs.Cryo)

local SetPackagePermission = require(Plugin.Core.Actions.SetPackagePermission)
local NetworkError = require(Plugin.Core.Actions.NetworkError)

local PermissionsConstants = require(Plugin.Core.Components.AssetConfiguration.Permissions.PermissionsConstants)
local KeyConverter = require(Plugin.Core.Util.Permissions.KeyConverter)

local Analytics = require(Plugin.Core.Util.Analytics.Analytics)

local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

local function deserializeResults(results)
	local idToPermissionsTable = {}
	for _, data in pairs(results) do
		idToPermissionsTable = Cryo.Dictionary.join(idToPermissionsTable,{
			[data.assetId] = KeyConverter.getInternalAction(data.action)
		})
	end

	return idToPermissionsTable
end

return function(networkInterface, assetIds)
	return function(store)

		local noAccessTable = {}
		for _, assetId in pairs(assetIds) do
			noAccessTable[assetId] = PermissionsConstants.NoAccessKey
		end
		store:dispatch(SetPackagePermission(noAccessTable))

		return networkInterface:getPackageHighestPermission(assetIds):andThen(
			function(result)
				if FFlagNewPackageAnalyticsWithRefactor2 then
				    Analytics.sendResultToKibana(result)
				end
				local resultData = result.responseBody
				local decodedResult = HttpService:JSONDecode(resultData).permissions
				local deserializeResultData = deserializeResults(decodedResult)

				store:dispatch(SetPackagePermission(deserializeResultData))
			end, 
			function(err)
				if FFlagNewPackageAnalyticsWithRefactor2 then
				    Analytics.sendResultToKibana(err)
				end
				store:dispatch(NetworkError(err))
			end)
	end
end
