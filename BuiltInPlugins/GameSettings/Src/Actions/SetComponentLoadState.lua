local Plugin = script.Parent.Parent.Parent
local Action = require(Plugin.Framework.Util).Action

local LoadState = require(Plugin.Src.Util.LoadState)
local loadStateMin = 0
local loadStateMax = 0

for _,v in pairs(LoadState) do
    loadStateMin = math.min(loadStateMin, v)
    loadStateMax = math.max(loadStateMax, v)
end

return Action(script.Name, function(componentName, loadState)    
    assert(typeof(componentName) == "string",
        string.format(script.Name.." requires componentName to be a string, not %s", typeof(componentName)))
    assert(typeof(loadState) == "number" and loadState >= loadStateMin and loadState <= loadStateMax,
        string.format(script.Name.." requires loadState to be a LoadState, not %s", typeof(loadState)))
    
    return {
        componentName = componentName,
        loadState = loadState,
    }
end)
