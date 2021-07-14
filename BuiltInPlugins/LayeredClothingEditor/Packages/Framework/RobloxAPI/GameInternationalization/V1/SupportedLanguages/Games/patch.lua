--[[
	Add or remove supported languages for a game

	Example Url: https://gameinternationalization.roblox.com/v1/supported-languages/games/1187272663
	Example Body:
	[
		{
			"languageCodeType": "Language",
			"languageCode": "en",
			"delete": false
		},
		...
	]

	Documented at : https://gameinternationalization.roblox.com/docs
]]
return function(networkingImpl, baseUrl)
	return function(gameId, body)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))
		assert(type(body) == "string",
			string.format("body must be string, received %s", type(body)))

		local url = baseUrl.composeUrl(
			baseUrl.GAMES_INTERNATIONALIZATION_URL, string.format("v1/supported-languages/games/%d", gameId))

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