--[[
	Generates localization asset of a game

	Example Url: https://localizationtables.roblox.com/v1/auto-localization-table/games/2152470364/assets-generation-request

	Documented at : https://localizationtables.roblox.com/docs
]]
return function(networkingImpl, baseUrl)
	return function(universeId)
		assert(type(universeId) == "number",
			string.format("universeId must be number, received %s", type(universeId)))

		local url = baseUrl.composeUrl(
			baseUrl.LOCALIZATION_TABLES_URL,
				string.format("v1/auto-localization-table/games/%d/assets-generation-request", universeId))

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
