--[[
	Returns a list of packages given a universe ID

	Example
	https://develop.roblox.com/v2/universes/1552514118/configuration

	Documented at : https://develop.roblox.com/docs/

	Returns a JSON table with these fields :
    {
        "id": 0,
        "name": "string",
        "description": "string",
        "universeAvatarType": "MorphToR6",
        "universeAnimationType": "Standard",
        "universeCollisionType": "InnerBox",
        "universeJointPositioningType": "Standard",
        "isArchived": true,
        "isFriendsOnly": true,
        "genre": "All",
        "playableDevices": [
            "Computer"
        ],
        "isForSale": true,
        "price": 0,
        "universeAvatarAssetOverrides": [
            {
            "assetID": 0,
            "assetTypeID": 0,
            "isPlayerChoice": true
            }
        ],
        "universeAvatarMinScales": {
            "height": 0,
            "width": 0,
            "head": 0,
            "depth": 0,
            "proportion": 0,
            "bodyType": 0
        },
        "universeAvatarMaxScales": {
            "height": 0,
            "width": 0,
            "head": 0,
            "depth": 0,
            "proportion": 0,
            "bodyType": 0
        },
        "studioAccessToApisAllowed": true
    }

]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- universeId : id of universe
    return function(universeId)
        assert(type(universeId) == "number",
            string.format("universeId must be number, received %s", type(universeId)))

		local url = baseUrl.composeUrl(baseUrl.DEVELOP_URL, string.format("v2/universes/%d/configuration", universeId))

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