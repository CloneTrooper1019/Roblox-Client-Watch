local GA_CATEGORY_ACTION = "Action"
local ASSET_MANAGER_CATEGORY = "LayeredClothingEditor"

return function(rbxAnalyticsService)
    return {
        --[[
        <handlerName> = function(<params>)
            rbxAnalyticsService:TrackEvent(GA_CATEGORY_ACTION, ASSET_MANAGER_CATEGORY, <params>)
            rbxAnalyticsService:ReportCounter("Name", 1)
        end,
        ]]
    }
end