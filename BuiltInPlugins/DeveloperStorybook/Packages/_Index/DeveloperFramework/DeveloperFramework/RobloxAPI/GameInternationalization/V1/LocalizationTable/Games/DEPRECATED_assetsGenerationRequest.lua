--[[
	Generates localization asset of a game

	Example Url: https://gameinternationalization.roblox.com/v1/localizationtable/games/1187272663/assets-generation-request

	Documented at : https://gameinternationalization.roblox.com/docs
]]
return function(networkingImpl, baseUrl)
	return function(gameId, body)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(
			baseUrl.GAMES_INTERNATIONALIZATION_URL,
				string.format("v1/localizationtable/games/%d/assets-generation-request", gameId))

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
