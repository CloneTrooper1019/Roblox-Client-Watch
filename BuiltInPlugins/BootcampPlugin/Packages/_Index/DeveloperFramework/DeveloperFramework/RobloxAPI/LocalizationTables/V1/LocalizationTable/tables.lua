--[[
	Updates the tables contents based on what is provided.

	Documented at : https://localizationtables.roblox.com/docs
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- tableId : string of tableId
	-- gameId : number of gameId
	-- body : string of encoded patchInfo
	return function(tableId, gameId, body)
		assert(type(tableId) == "string",
			string.format("tableId must be string, received %s", type(tableId)))
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))
		assert(type(body) == "string",
			string.format("patch must be string, received %s", type(body)))

		local url = baseUrl.composeUrl(baseUrl.LOCALIZATION_TABLES_URL,
			string.format("v1/localization-table/tables/%s?gameId=%d", tableId, gameId))

		local headers = {
			["Content-Type"] = "application/json"
		}

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:patch(url, body, headers)
				return networkingImpl:parseJson(httpPromise)
			end,
		}

	end
end