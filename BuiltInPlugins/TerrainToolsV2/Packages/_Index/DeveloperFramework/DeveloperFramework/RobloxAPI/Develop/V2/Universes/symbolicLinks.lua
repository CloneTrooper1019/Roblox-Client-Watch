--[[
	Returns a list of packages given a universe ID

	Example
	https://develop.roblox.com/v2/universes/1552514118/symbolic-links

	Documented at : https://develop.roblox.com/docs/

	Returns a JSON table with these fields :
	{
        "previousPageCursor": "string",
        "nextPageCursor": "string",
        "data": [
            {
            "id": "00000000-0000-0000-0000-000000000000",
            "placeId": 0,
            "assetId": 0,
            "name": "Name",
            "assetVersionNumber": 0
            }
        ]
    }
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- universeId : id of universe
    -- limit : number of assets to request
    -- sortOrder : sorting order of assets returned
    -- cursor : cursor of page to request
    return function(universeId, cursor, limit, sortOrder)
        assert(type(universeId) == "number",
            string.format("universeId must be number, received %s", type(universeId)))
        if cursor then
            assert(type(cursor) == "string",
                string.format("cursor must be number, received %s", type(cursor)))
        end
        limit = limit or 10
        assert(type(limit) == "number",
            string.format("limit must be number, received %s", type(limit)))
        sortOrder = sortOrder or "Asc"
        assert(type(sortOrder) == "string",
            string.format("sortOrder must be string, received %s", type(sortOrder)))

		local url = baseUrl.composeUrl(baseUrl.DEVELOP_URL, string.format("v2/universes/%d/symbolic-links", universeId), {
			limit = limit,
            sortOrder = sortOrder,
            cursor = cursor,
		})

		return {
			getUrl = function()
				return url
			end,

            makeRequest = function()
				local httpPromise = networkingImpl:get(url)
				local retryPromise = networkingImpl:handleRetry(httpPromise)
				return networkingImpl:parseJson(retryPromise)
			end,
		}
	end
end