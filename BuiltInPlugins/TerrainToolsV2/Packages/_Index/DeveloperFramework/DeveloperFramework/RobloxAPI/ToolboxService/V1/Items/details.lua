--[[
	Returns details of Toolbox items.
	Example Request :
	{
		"items": [
			{
				"id": 1,
				"itemType": "Asset"
			}
		]
	}

	Example :
	https://apis.roblox.com/toolbox-service/v1/items/details
]]

local HttpService = game:GetService("HttpService")

local Framework = script.Parent.Parent.Parent.Parent.Parent
local t = require(Framework.Util.Typecheck.t)

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)

	return function(itemsToRequest)
		assert(t.strictInterface({
			items = t.array(t.strictInterface({
				id = t.integer,
				itemType = t.string,
			}))
		})(itemsToRequest), "Request does not match expected format")

		local url = baseUrl.composeUrl(baseUrl.APIS_URL, "toolbox-service/v1/items/details")

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:post(url, HttpService:JSONEncode(itemsToRequest), {
					["Content-Type"] = "application/json",
				})
				-- TODO DEVTOOLS-4914: This will not retry because POST is non-idempotent in REST, but this endpoint is apparently
				-- only POST method to facilitate passing a request body, so do we want to retry it?
				return networkingImpl:parseJson(networkingImpl:handleRetry(httpPromise))
			end,
		}
	end
end