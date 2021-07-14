--[[
	A set of utilities for accessing FACS.
]]

local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local Cryo = require(Plugin.Packages.Cryo)

local FacsUtils = {}

function FacsUtils.filterFacsTracks(tracks)
    local facs = {}
    for _, track in pairs(tracks) do
        if track.Type == Constants.TRACK_TYPES.Facs then
            table.insert(facs, track)
        end
    end

    return facs
end

function FacsUtils.getUnusedFacs(tracks)
    local unusedFacs = {}

    for facsName, _ in pairs(Constants.FacsControlToRegionMap) do
        unusedFacs[facsName] = {
            Name = facsName,
            Instance = "Root",
            Type = Constants.TRACK_TYPES.Facs
        }
    end

    for _, facs in pairs(tracks) do
        unusedFacs[facs.Name] = nil
    end

    unusedFacs = Cryo.Dictionary.values(unusedFacs)

    table.sort(unusedFacs, function(first, second)
        return first.Name < second.Name
    end)

    return unusedFacs
end

return FacsUtils