--[[
	Provides a single location for base url construction. It stays up to date with ContentProvider.

	Optional Props:
		string baseUrl: the base domain to use when constructing Roblox Urls.


	Functions:
		Url.new(optional string baseUrl):
			Constructs a container that hosts all of the different Roblox subdomains.
			If you don't supply a baseUrl, it will default to ContentProvider's BaseUrl.

		Url.composeUrl(string base, string apiPath, optional table args):
			Constructs a url given the supplied pieces.

	Example Usage:
		local url = Url.new()
		local targetUrl = url.composeUrl(url.BASE_URL, "games", {
			SortFilter = "default",
			TimeFilter = "0"
		}
		print(targetUrl) -- https://www.roblox.com/games?SortFilter=default&TimeFilter=0
]]

local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

-- helper functions
local function parseBaseUrlInformation(baseUrl)
	-- keep a copy of the base url and append a trailing slash if there isn't one
	if baseUrl:sub(#baseUrl) ~= "/" then
		baseUrl = baseUrl .. "/"
	end

	-- parse out scheme (http, https)
	local _, schemeEnd = baseUrl:find("://")

	-- parse out the prefix (www, kyle, ying, etc.)
	local prefixIndex, prefixEnd = baseUrl:find("%.", schemeEnd + 1)
	local basePrefix = baseUrl:sub(schemeEnd + 1, prefixIndex - 1)

	-- parse out the domain
	local baseDomain = baseUrl:sub(prefixEnd + 1)

	return baseUrl, basePrefix, baseDomain
end


local Url = {}
Url.__index = Url

-- baseUrl : (string, optional) a url to use as the root for all url constructions
function Url.new(baseUrl)
	if baseUrl then
		assert(type(baseUrl) == "string", "Expected baseUrl to be a string")
	else
		baseUrl = ContentProvider.BaseUrl
	end

	local _baseUrl, _, _baseDomain = parseBaseUrlInformation(baseUrl)

	local url = {
		BASE_URL = _baseUrl,  -- https://www.roblox.com/

		API_URL = string.format("https://api.%s", _baseDomain),
		APIS_URL = string.format("https://apis.%s", _baseDomain),
		ASSET_GAME_URL = string.format("https://assetgame.%s", _baseDomain),
		AUTH_URL = string.format("https://auth.%s", _baseDomain),
		CATALOG_URL = string.format("https://catalog.%s", _baseDomain),
		CHAT_URL = string.format("https://chat.%s", _baseDomain),
		DATA_URL = string.format("https://data.%s", _baseDomain),
		DEVELOP_URL = string.format("https://develop.%s", _baseDomain),
		GAMES_INTERNATIONALIZATION_URL = string.format("https://gameinternationalization.%s", _baseDomain),
		GAMES_URL = string.format("https://games.%s", _baseDomain),
		GROUPS_URL = string.format("https://groups.%s", _baseDomain),
		ITEM_CONFIGURATION_URL = string.format("https://itemconfiguration.%s", _baseDomain),
		LOCALE_URL = string.format("https://locale.%s", _baseDomain),
		LOCALIZATION_TABLES_URL = string.format("https://localizationtables.%s", _baseDomain),
		NOTIFICATIONS_URL = string.format("https://notifications.%s", _baseDomain),
		PUBLISH_URL = string.format("https://publish.%s", _baseDomain),
		REALTIME_URL = string.format("https://realtime.%s", _baseDomain),
		TRANSLATION_ROLES_URL = string.format("https://translationroles.%s", _baseDomain),
		WEB_URL = string.format("https://web.%s", _baseDomain),
	}
	setmetatable(url, Url)

	return url
end

-- base : (string) the root domain.  ex) https://www.roblox.com/
-- path : (string) the path to the api. ex) some/api/path
-- args : (optional, map<string, Variant>) arguments to append to the url. ex) { test="123", foo="456" }
function Url.composeUrl(base, path, args)
	assert(type(base) == "string", "Expected 'base' to be a string.")
	assert(type(path) == "string", "Expected 'path' to be a string.")
	if args then
		assert(type(args) == "table", "Expected 'args' to be a map.")
		assert(type((next(args))) == "string", "Expected 'args' to be map, not an array.")
	end

	-- append a slash to the end if the base doesn't have one
	if base:sub(#base) ~= "/" then
		base = base .. "/"
	end

	-- construct the url argument string
	local argString = ""
	if args then
		local argList = {}
		for key, argument in pairs(args) do
			if type(argument) == "userdata" then
				error(string.format("Userdata values are not supported as arguments. Please update argument : %s", key))

			elseif type(argument) == "table" then
				if #argument == 0 and next(argument) ~= nil then
					error(string.format("Nested maps as arguments are not supported. Please update argument : %s", key))
				elseif #argument == 0 then
					error(string.format("Empty arrays are not supported. Please update argument : %s", key))
				else
					-- THIS IS NOT SUPPORTED ON ALL BACKEND SYSTEMS. BE VERY CAREFUL WHEN PASSING IN ARRAYS
					local processedArgs = {}
					for _, arg in ipairs(argument) do
						table.insert(processedArgs, HttpService:UrlEncode(arg))
					end
					table.insert(argList, string.format("%s=%s", key, table.concat(processedArgs, ",")))
				end
			else
				argument = HttpService:UrlEncode(argument)
				table.insert(argList, string.format("%s=%s", key, tostring(argument)))
			end
		end
		if #argList > 0 then
			argString = "?" .. table.concat(argList, "&")
		end
	end

	-- put it all together like https://www.somedomain.com/some/api/path?test=123&foo=456
	return string.format("%s%s%s", base, path, argString)
end

return Url
