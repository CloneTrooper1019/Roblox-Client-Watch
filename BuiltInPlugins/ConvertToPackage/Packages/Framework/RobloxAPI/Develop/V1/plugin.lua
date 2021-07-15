--[[
	Returns information about the list of provided pluginIds

	Example
	https://develop.roblox.com/v1/plugins?pluginIds=3454668784,165687726

	Documented at : https://develop.roblox.com/docs/

	Returns a JSON table with these fields :
	"data": [
	{
		"id": 3454668784,
		"name": "test_plugin3",
		"description": "test_plugin3",
		"commentsEnabled": true,
		"versionId": 4170963656,
		"created": "2019-07-11T23:04:39.167Z",
		"updated": "2019-07-11T23:04:39.183Z"
	},
	{
		"id": 165687726,
		"name": "Stravant - GapFill & Extrude *Fixed*",
		"description": "A plugin that lets you \"fill in\" gaps between edges of an arbitrary
			selection of parts in your place, letting you do things that are pretty much
			impossible using the existing tools, such as creating smooth rolling contours on
			your creations. Also allows you to extrude faces of parts; double clicking on a
			part's face will create a new part by \"stretching\" that face out in the direction
			it is facing. Best used in conjunction with the ResizeAlign plugin also by me:
			############################################################
			MESSAGE ME WITH ANY BUGS THAT YOU FIND, PREFERABLY GIVE ME A LINK TO A YOUTUBE VID WITH THE PROBLEM",
		"commentsEnabled": true,
		"versionId": 1887335469,
		"created": "2014-07-10T20:40:37.74Z",
		"updated": "2018-02-12T04:14:51.047Z"
	}]
]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- pluginIds : (table<number> an array of assetIds)
	return function(pluginIds)
		assert(type(pluginIds) == "table", "Expected an array of pluginIds.")

		local url = baseUrl.composeUrl(baseUrl.DEVELOP_URL, "v1/plugins", {
			pluginIds = pluginIds
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