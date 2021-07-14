--[[
	Retrieves the list of roles granted to current logged-in user

	Example
	https://translationroles.roblox.com/v1/game-localization-roles/games/1187272663/current-user/roles

	Documented at : https://translationroles.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"data": [
			"owner",
			"translator"
		]
	}
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	return function(gameId)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(baseUrl.TRANSLATION_ROLES_URL,
			string.format("v1/game-localization-roles/games/%d/current-user/roles", gameId))

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