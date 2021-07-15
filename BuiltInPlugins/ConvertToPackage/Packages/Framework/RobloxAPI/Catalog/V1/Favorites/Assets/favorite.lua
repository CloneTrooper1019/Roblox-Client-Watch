--[[
    For GET, returns a response body in the following format if the asset is favorited
    {
        "assetId":185687363,
        "userId":989859360,
        "created":"2020-02-20T18:52:56.963Z"
    }
    returns null otherwise

	For DELETE, returns {} if unfavoriting was successful otherwise returns an error body, for example:
	{
		"errors": [
			{
				"code": 4,
				"message": "Asset is already not favorited.",
				"userFacingMessage": "Something went wrong"
			}
		]
	}

	For POST, returns {} if favoriting was successful, otherwise returns an error body, for example:
	{
		"errors": [
			{
				"code": 3,
				"message": "Asset is already favorited.",
				"userFacingMessage": "Something went wrong"
			}
		]
	}

	Example :
	https://catalog.roblox.com/v1/favorites/users/989859360/assets/183435411/favorite
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- assetId : (number/string) a number identifying a specific asset.
	-- userId : (number/string) a user's unique id.
	return function(assetId, userId, favorited)
		assert(tonumber(assetId) > 0, "Expected assetId to be a positive number.")
		assert(tonumber(userId) > 0,  "Expected userId to be a positive number.")

		local url = baseUrl.composeUrl(baseUrl.CATALOG_URL, string.format("v1/favorites/users/%s/assets/%s/favorite", userId, assetId))
		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise

				-- favorited is nil, then we're making the get request checking if the asset is already favorited
				-- favorited is true, then we're making the request to un-favorite the asset
				-- favorited is false, then we're making the request to favorite the asset
				if favorited == nil then
					httpPromise = networkingImpl:get(url)
				elseif favorited == true then
					httpPromise = networkingImpl:delete(url)
				elseif favorited == false then
					httpPromise = networkingImpl:post(url, "")
				end
				return networkingImpl:handleRetry(httpPromise)
			end,
		}
	end
end