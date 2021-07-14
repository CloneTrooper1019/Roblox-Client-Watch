--[[
	This endpoint returns HTML, use its url to open external windows

	Example:
	https://www.roblox.com/localization/games/1627082341/configure
]]

-- _ : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(_, baseUrl)
	return function(gameId)
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(baseUrl.BASE_URL, string.format("localization/games/%d/configure", gameId))

		return {
			getUrl = function()
				return url
			end,
		}
	end
end