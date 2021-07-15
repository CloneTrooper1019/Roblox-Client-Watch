-- Centralized Place for Keys used throughout the widget
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")
local FFlagGameSettingsEnableVoiceChat = game:GetFastFlag("GameSettingsEnableVoiceChat")

local KeyProvider = {}

function KeyProvider.getCopyIdKeyName()
    return "CopyIDToClipboard"
end

function KeyProvider.getConfigureKeyName()
    return "Configure"
end

function KeyProvider.getIsFriendOnlyKeyName()
    return "isFriendsOnly"
end

function KeyProvider.getIsActiveKeyName()
    return "isActive"
end

function KeyProvider.getIsForSaleKeyName()
    return "isForSale"
end

function KeyProvider.getVipServersIsEnabledKeyName()
    return "vipServersIsEnabled"
end

function KeyProvider.getEditKeyName()
    return "Edit"
end

function KeyProvider.getVersionHistoryKeyName()
    return "VersionHistory"
end

function KeyProvider.getOptInLocationsKeyName()
    assert(FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn)

    return "OptInLocations"
end

function KeyProvider.getChinaKeyName()
    assert(FFlagLuobuDevPublishLua)

    return "China"
end

function KeyProvider.getSelectedKeyName()
    assert(FFlagLuobuDevPublishLua)

    return "selected"
end

function KeyProvider.getVoiceChatEnabledKeyName()
    assert(FFlagGameSettingsEnableVoiceChat)

    return "VoiceChatEnabled"
end

function KeyProvider.getPlayerAcceptanceKeyName()
    assert(FFlagLuobuDevPublishLua)
    
    return "PlayerAcceptance"
end

return KeyProvider
