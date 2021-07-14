--[[
    POST
    Submit a contact email for Luobu moderators to send the developer remediation steps for universe & place moderation.
    Example:
    https://apis.roblox.com/studio-moderation/{universeId}/contacts
    POST Body
    {
        "email": "..@.."
    }
]]

local HttpService = game:GetService("HttpService")

local Framework = script.Parent.Parent.Parent.Parent
local t = require(Framework.Util.Typecheck.t)

-- networkingImpl : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(networkingImpl, baseUrl)
    -- universeId : the universeId for which the email should be submitted for
    return function(universeId, contactEmail)
        assert(t.number(universeId), string.format("universeId must be a number, received %s", type(universeId)))
        assert(t.string(contactEmail), string.format("contactEmail must be a string, received %s", type(contactEmail)))

        local url = baseUrl.composeUrl(baseUrl.APIS_URL, "studio-moderation/v1/" .. universeId .. "/contacts")

        return {
            getUrl = function()
                return url
            end,
            makeRequest = function()
                local httpPromise = networkingImpl:post(url, HttpService:JSONEncode({
                    email = contactEmail
                }),{
                    ["Content-Type"] = "application/json",
                })
                return networkingImpl:parseJson(httpPromise)
            end,
        }
    end
end
