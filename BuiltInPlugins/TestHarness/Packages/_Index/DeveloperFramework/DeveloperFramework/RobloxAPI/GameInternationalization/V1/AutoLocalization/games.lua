--[[
	Get or create cloud localization table for a game
	Returns a table of auto localization setting info

	Example
	https://gameinternationalization.roblox.com/v1/autolocalization/games/1187272663/autolocalizationtable

	Documented at : https://gameinternationalization.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"isAutolocalizationEnabled": true,
		"shouldUseLocalizationTable": true,
		"autoLocalizationTableId": "4dc5c30d-9011-45f3-b771-83d4726da878",
		"assetId": 3298565315
	}

]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	return function(gameId)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(baseUrl.GAMES_INTERNATIONALIZATION_URL,
			string.format("v1/autolocalization/games/%d/autolocalizationtable", gameId))

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:post(url, "")
				return networkingImpl:parseJson(httpPromise)
			end,
		}
	end
end