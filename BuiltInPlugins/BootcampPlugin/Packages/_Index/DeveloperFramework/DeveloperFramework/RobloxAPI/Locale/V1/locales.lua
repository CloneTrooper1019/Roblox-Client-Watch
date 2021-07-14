--[[
	Returns a list of supported locales

	Example
	https://locale.roblox.com/v1/locales?displayValueLocale=en_us

	Documented at : https://locale.roblox.com/docs

	Returns a JSON table with these fields :
	{
		"data": [
			{
				"locale": {
					"id": 1,
					"locale": "en_us",
					"name": "English(US)",
					"nativeName": "English",
					"language": {
						"id": 41,
						"name": "English",
						"nativeName": "English",
						"languageCode": "en"
					}
				},
				"isEnabledForFullExperience": true,
				"isEnabledForSignupAndLogin": true,
				"isEnabledForInGameUgc": true
			},
			...
		]
	}

]]

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
	-- optional localeCode : (string of localeCode, UNDERSCORE as delimiter)
	return function(displayValueLocaleCode)
		if displayValueLocaleCode then
			assert(type(displayValueLocaleCode) == "string",
				string.format("localeCode must be string, received %s", type(displayValueLocaleCode)))
		end

		local args = displayValueLocaleCode ~= nil and {displayValueLocaleCode = displayValueLocaleCode}
		local url = baseUrl.composeUrl(baseUrl.LOCALE_URL, "v1/locales", args)

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