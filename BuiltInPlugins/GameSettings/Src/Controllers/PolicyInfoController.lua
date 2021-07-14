local PolicyInfoController = {}
PolicyInfoController.__index = PolicyInfoController

function PolicyInfoController.new(networking)
    local self = {}

    self.__networking = networking

    return setmetatable(self, PolicyInfoController)
end

local function appAgreementsResolutionV1GET(networking)
    return networking:get("apis", "/user-agreements/v1/agreements-resolution/App")
end

local function studioModerationContactPOST(networking, universeId, contactEmail)
    return networking:post("apis", "/studio-moderation/v1/" .. universeId .. "/contacts", {
        Body = {
            email = contactEmail
        }
    })
end

function PolicyInfoController:getPlayerAcceptances()
    local networking = self.__networking
    local response = appAgreementsResolutionV1GET(networking):await()

    return next(response.responseBody) == nil
end

function PolicyInfoController:postContactEmail(universeId, contactEmail)
    assert(type(universeId) == "number",
        string.format("universeId must be a number, received %s", type(universeId)))
    assert(type(contactEmail) == "string",
        string.format("contactemail must be a string, received %s", type(contactEmail)))

    local networking = self.__networking

    local responseCode
    studioModerationContactPOST(networking, universeId, contactEmail):catch(
        function(response)
            responseCode = response.responseCode
        end
    ):await()

    return responseCode
end

return PolicyInfoController
