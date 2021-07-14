--[[
	Returns true/false whether the provided user owns the specified asset
	
	Example :
	https://api.roblox.com/ownership/hasasset?assetId=144358935&userId=48103520
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- assetId : (number/string) a number identifying a specific asset.
	-- userId : (number/string) a user's unique id.
	return function(assetId, userId)
		assert(tonumber(assetId) > 0, "Expected assetId to be a positive number.")
		assert(tonumber(userId) > 0,  "Expected userId to be a positive number.")

		local url = baseUrl.composeUrl(baseUrl.API_URL, "ownership/hasasset", {
			assetId = assetId,
			userId = userId,
		})

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