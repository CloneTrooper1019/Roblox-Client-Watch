--[[
	This thunk is used to add a new track to the Animation Editor.

	Parameters:
		string instanceName: The name of the instance this track belongs to.
		string trackName: The name to use for the new track.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local Templates = require(Plugin.Src.Util.Templates)
local SortAndSetTracks = require(Plugin.Src.Thunks.SortAndSetTracks)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local function wrappee(instanceName, trackName, trackType, analytics)
	return function(store)
		local state = store:getState()
		local status = state.Status

		if status == nil then
			return
		end

		local tracks = status.Tracks

		for _, track in ipairs(tracks) do
			if track.Name == trackName then
				return
			end
		end

		local newTrack = Templates.trackListEntry()
		newTrack.Name = trackName
		newTrack.Instance = instanceName
		if GetFFlagFacialAnimationSupport() then
			newTrack.Type = trackType
		end

		local newTracks = Cryo.List.join(tracks, {newTrack})

		store:dispatch(SortAndSetTracks(newTracks))
		if analytics then
			analytics:report("onTrackAdded", trackName)
		end
	end
end

if GetFFlagFacialAnimationSupport() then
	return function(instanceName, trackName, trackType, analytics)
		return wrappee(instanceName, trackName, trackType, analytics)
	end
else
	return function(instanceName, trackName, analytics)
		return wrappee(instanceName, trackName, nil, analytics)
	end
end