--[[
	Get the supported languages for a game

	Example
	https://gameinternationalization.roblox.com/v1/supported-languages/games/1187272663

	Documented at : https://gameinternationalization.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"data": [
			{
				"name": "Spanish",
				"languageCodeType": "Language",
				"languageCode": "es"
			},
			{
				"name": "English",
				"languageCodeType": "Language",
				"languageCode": "en"
			},
			...
		]
	}

]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	return function(gameId)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(
			baseUrl.GAMES_INTERNATIONALIZATION_URL, string.format("v1/supported-languages/games/%d", gameId))

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:get(url)
				return networkingImpl:parseJson(httpPromise)
			end,
		}
	end
end