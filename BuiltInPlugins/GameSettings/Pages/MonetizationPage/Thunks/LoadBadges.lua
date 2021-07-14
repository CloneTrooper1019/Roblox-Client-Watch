--[[
	Called on scroll to load more Badges, or to refresh badges if refreshing == true
]]
local Plugin = script.Parent.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetCurrentSettings = require(Plugin.Src.Actions.SetCurrentSettings)

return function(refreshing)
    return function(store, contextItems)
        local state = store:getState()
        local gameId = state.Metadata.gameId
        local currentCursor = nil
        
        if not refreshing then
            currentCursor = state.Settings.Current.badgesCursor

            if currentCursor == nil then
                return
            end
        end

        local monetizationController = contextItems.monetizationController

        local badges, cursor = monetizationController:getBadges(gameId, currentCursor)
        local settings = state.Settings.Current
        
        if refreshing then
            cursor = nil
        else
            local currentBadges = state.Settings.Current.badges and state.Settings.Current.badges or {}
            badges = Cryo.Dictionary.join(currentBadges, badges)
        end
        
        settings = Cryo.Dictionary.join(settings, {
            badgesCursor = cursor,
            badges = badges,
        })

        store:dispatch(SetCurrentSettings(settings))
    end
end
