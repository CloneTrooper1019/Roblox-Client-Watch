--[[
No-op Analytics replacement which the unit tests direct logging to.
]]

local Analytics = {}

function Analytics:sendEvent(eventName, argMap)
end

function Analytics:reportCounter(counterName, count)
end

function Analytics:reportStats(statName, value)
end

return Analytics