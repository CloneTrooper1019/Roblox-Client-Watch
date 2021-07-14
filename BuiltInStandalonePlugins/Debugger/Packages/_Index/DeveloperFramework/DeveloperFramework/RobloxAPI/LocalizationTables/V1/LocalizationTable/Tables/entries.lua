--[[
	Gets a batch of entries for a table

	Example
	https://localizationtables.roblox.com/v1/localization-table/tables/4dc5c30d-9011-45f3-b771-83d4726da878/entries?gameId=1187272663

	Documented at : https://localizationtables.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"previousPageCursor": null,
		"nextPageCursor": null,
		"data": [
			{
				"identifier": {
					"key": null,
					"context": null,
					"source": "Number {1:num} (ServerCloud, untranslated)"
				},
				"metadata": {
					"example": null,
					"gameLocations": null
				},
				"translations": [
					{
						"locale": "es",
						"translationText": "Number {1:num} (ServerCloud, es)"
					},
					{
						"locale": "fr",
						"translationText": "Number {1:num} (ServerCloud, fr)"
					},
				]
			},
			...
		]
	}
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- cursor : page cursor from the response. For first call, you may use empty string.
	return function(tableId, cursor, gameId)
		assert(type(tableId) == "string",
			string.format("tableId must be string, received %s", type(tableId)))
		assert(type(cursor) == "string",
			string.format("cursor must be string, received %s", type(cursor)))
		assert(type(gameId) == "number",
			string.format("gameId must be number, received %s", type(gameId)))

		local url = baseUrl.composeUrl(baseUrl.LOCALIZATION_TABLES_URL,
			string.format("v1/localization-table/tables/%s/entries?cursor=%s&gameId=%d", tableId, cursor, gameId))

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