--[[
	Returns a list of packages given a universe ID

	Example
	https://develop.roblox.com/v1/packages/highest-permissions

	Documented at : https://develop.roblox.com/docs/

	Returns a JSON table with these fields :
	{
        "permissions": [
            {
            "hasPermission": true,
            "assetId": 0,
            "action": "UseView",
            "upToVersion": 0
            }
        ],
        "invalidAssetIds": [
            0
        ]
    }
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- assetIds - list of asset ids to fetch permissions for
    return function(assetIds)
        assert(type(assetIds) == "table",
            string.format("assetIds must be number, received %s", type(assetIds)))

		local url = baseUrl.composeUrl(baseUrl.DEVELOP_URL, "v1/packages/highest-permissions", {
			assetIds = assetIds,
		})

		return {
			getUrl = function()
				return url
			end,

            makeRequest = function()
				local httpPromise = networkingImpl:get(url)
				local retryPromise = networkingImpl:handleRetry(httpPromise)
				return networkingImpl:parseJson(retryPromise)
			end,
		}
	end
end