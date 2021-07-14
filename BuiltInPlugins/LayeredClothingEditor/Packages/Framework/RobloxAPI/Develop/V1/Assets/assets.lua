--[[
	Returns a list of asset data given a list of asset ids

	Example
	https://develop.roblox.com/v1/assets?assetIds=assetId1,assetId2

	Documented at : https://develop.roblox.com/docs/

	Returns a JSON table with these fields :
{
  "data": [
    {
      "id": assetId1,
      "type": "Model",
      "typeId": 10,
      "name": "assetname1",
      "description": "asset description",
      "creator": {
        "type": "User",
        "typeId": 1,
        "targetId": userId
      },
      "genres": [
        "All"
      ],
      "created": "2020-03-04T01:17:42.253Z",
      "updated": "2020-03-04T01:17:42.09Z",
      "enableComments": false,
      "isCopyingAllowed": false,
      "isPublicDomainEnabled": false,
      "moderationStatus": "Green",
      "isModerated": true,
      "isVersioningEnabled": true,
      "isArchivable": false,
      "canHaveThumbnail": false
    }
  ]
}
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- assetIds - list of asset ids to fetch permissions for
    return function(assetIds)
      assert(type(assetIds) == "table",
          string.format("assetIds must be table, received %s", type(assetIds)))

		local url = baseUrl.composeUrl(baseUrl.DEVELOP_URL, "v1/assets", {
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