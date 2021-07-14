--[[
	Gets the source language of a game

	Example:
	https://gameinternationalization.roblox.com/v1/source-language/games/1187272663

	Documented at : https://gameinternationalization.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"name": "English",
		"nativeName": "English",
		"languageCode": "en"
	}

]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	return function(universeId)
		assert(type(universeId) == "number",
			string.format("universeId must be number, received %s", type(universeId)))

		local url = baseUrl.composeUrl(
			baseUrl.GAMES_INTERNATIONALIZATION_URL, string.format("v1/source-language/games/%d", universeId))

		return {
			getUrl = function()
				return url
			end,

			makeRequest = function()
				local httpPromise = networkingImpl:get(url)
				return networkingImpl:parseJson(networkingImpl:handleRetry(httpPromise))
			end,
		}
	end
end
