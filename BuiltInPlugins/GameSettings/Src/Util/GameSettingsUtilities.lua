-- TODO: jbousellam - 3/16/21 - remove with FFlagStudioCreatePluginPolicyService
local Plugin = script.Parent.Parent.Parent
local isCJV = require(Plugin.Src.Util.isCJV)

local FFlagStudioCreatePluginPolicyService = game:GetFastFlag("StudioCreatePluginPolicyService")
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")

local StudioService = game:GetService("StudioService")

local GameSettingsPolicy = FFlagStudioCreatePluginPolicyService and game:GetService("PluginPolicyService"):getPluginPolicy("GameSettings") or nil

local GameSettingsUtilities =  {}

local function checkIfPolicyDoesNotExistAndBaseUrlChineseHost()
    return not FFlagStudioCreatePluginPolicyService and StudioService:BaseURLHasChineseHost()
end

local function checkIfPolicyDoesNotExistAndBaseUrlNotChineseHost()
    return not FFlagStudioCreatePluginPolicyService and not StudioService:BaseURLHasChineseHost()
end

function GameSettingsUtilities.getAutoTranslationAllowed()
    return (not FFlagStudioCreatePluginPolicyService and isCJV())
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["AutoTranslationAllowed"])
end

function GameSettingsUtilities.getAutoTranslatedLanguages()
    return GameSettingsPolicy["AutoTranslationTargetLanguages"]
end

function GameSettingsUtilities.getSocialMediaReferencesAllowed()
    return checkIfPolicyDoesNotExistAndBaseUrlNotChineseHost()
	    or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["SocialMediaReferencesAllowed"])
end

function GameSettingsUtilities.shouldDisablePrivateServersAndPaidAccess()
    return checkIfPolicyDoesNotExistAndBaseUrlChineseHost()
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["DisablePrivateServersAndPaidAccess"])
end

function GameSettingsUtilities.shouldAllowBadges()
    return (not FFlagStudioCreatePluginPolicyService and not StudioService:BaseURLHasChineseHost())
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["ShowBadges"])
end

function GameSettingsUtilities.shouldShowDevPublishLocations()
    assert(FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn)

    return checkIfPolicyDoesNotExistAndBaseUrlChineseHost()
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["ShowOptInLocations"])
end

function GameSettingsUtilities.getPlayerAppDownloadLink(location)
    assert(FFlagLuobuDevPublishLua)

    return (checkIfPolicyDoesNotExistAndBaseUrlChineseHost() and "https://www.roblox.qq.com")
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["PlayerAppDownloadLink"][location])
end

function GameSettingsUtilities.getOptInLocationsRequirementsLink(location)
    assert(FFlagLuobuDevPublishLua)

    return (checkIfPolicyDoesNotExistAndBaseUrlChineseHost() and "https://www.roblox.qq.com")
        or (FFlagStudioCreatePluginPolicyService and GameSettingsPolicy["OptInLocationsRequirements"][location])
end

return GameSettingsUtilities
