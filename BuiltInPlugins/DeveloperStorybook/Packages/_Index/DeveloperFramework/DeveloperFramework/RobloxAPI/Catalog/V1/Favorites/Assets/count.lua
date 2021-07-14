--[[
    Returns the number of favorites an asset has
    Example :
    1952

	Example :
	https://catalog.roblox.com/v1/favorites/assets/4790882375/count
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- assetId : (number/string) a number identifying a specific asset.

	return function(assetId)
		assert(tonumber(assetId) > 0, "Expected assetId to be a positive number.")

		local url = baseUrl.composeUrl(baseUrl.CATALOG_URL, string.format("v1/favorites/assets/%s/count", assetId))

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:get(url)
				return networkingImpl:handleRetry(httpPromise)
			end,
		}
	end
end