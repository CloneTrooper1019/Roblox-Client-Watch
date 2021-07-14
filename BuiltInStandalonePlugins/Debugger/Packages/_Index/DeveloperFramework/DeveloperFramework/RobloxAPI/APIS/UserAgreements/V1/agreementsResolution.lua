--[[
    Returns a list of agreements the user needs to accept
    Returns an empty list if the user has accepted all necessary agreements.
    Example:
    https://apis.roblox.com/user-agreements/v1/agreements-resolution/App
    [
        {
            "displayUrl": "https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use",
            "id": "da2aa0e0-f408-47a3-88a0-0e68b7a8481c",
            "agreementType": "TermsOfService",
            "clientType": "App",
            "regulationType": "Global"
        },
        {
            "displayUrl": "https://en.help.roblox.com/hc/en-us/articles/115004630823-Roblox-Privacy-and-Cookie-Policy-",
            "id": "84d3847e-d8d8-4159-a540-9ae31d3fe26c",
            "agreementType": "PrivacyPolicy",
            "clientType": "App",
            "regulationType": "Global"
        }
    ]
]]
-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- application name : name of application for which acceptances to query. "App" or "Studio"
    return function(applicationName)
        assert(type(applicationName) == "string",
            string.format("applicationName must be a string, received %s", type(applicationName)))
        local url = baseUrl.composeUrl(baseUrl.APIS_URL, "user-agreements/v1/agreements-resolution/" .. applicationName)
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