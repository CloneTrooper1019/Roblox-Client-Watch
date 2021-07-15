local Plugin = script.Parent.Parent.Parent.Parent

local HttpService = game:GetService("HttpService")

local Actions = Plugin.Core.Actions
local Analytics = require(Plugin.Core.Util.Analytics.Analytics)
local SetIsPackage = require(Actions.SetIsPackage)
local NetworkError = require(Actions.NetworkError)

local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")

return function(networkInterface, assetId)
    return function(store)
        return networkInterface:postForPackageMetadata(assetId):andThen(
            function(result)
                if FFlagNewPackageAnalyticsWithRefactor2 then
                    Analytics.sendResultToKibana(result)
                end
                local response = result.responseBody.data[1]
                if response and response.assetId and response.assetVersionNumber then
                    store:dispatch(SetIsPackage(true))
                else
                    store:dispatch(SetIsPackage(false))
                end
            end,
            function(err)
                if FFlagNewPackageAnalyticsWithRefactor2 then
                    Analytics.sendResultToKibana(err)
                end
                store:dispatch(SetIsPackage(false))
                store:dispatch(NetworkError(err))
            end
        )
    end
end