--[[
	Adds a single keyframe at the given track and frame.
	Sets the keyframe's value to the given value.
]]
local Plugin = script.Parent.Parent.Parent

local deepCopy = require(Plugin.Src.Util.deepCopy)
local AnimationData = require(Plugin.Src.Util.AnimationData)
local AddTrack = require(Plugin.Src.Thunks.AddTrack)
local UpdateAnimationData = require(Plugin.Src.Thunks.UpdateAnimationData)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local function wrappee(instanceName, trackName, trackType, frame, value, analytics)
	return function(store)
		local state = store:getState()
		local animationData = state.AnimationData
		if not animationData then
			return
		end

		local newData = deepCopy(animationData)

		local instance = newData.Instances[instanceName]
		if instance == nil then
			return
		end

		-- Add the track if it does not exist
		local tracks = instance.Tracks
		if tracks[trackName] == nil then
			if GetFFlagFacialAnimationSupport() then
				store:dispatch(AddTrack(instanceName, trackName, trackType, analytics))
			else
				store:dispatch(AddTrack(instanceName, trackName, analytics))
			end
			AnimationData.addTrack(tracks, trackName, trackType)
		end
		local track = tracks[trackName]
		local trackData = track.Data

		if trackData[frame] == nil then
			AnimationData.addKeyframe(track, frame, value)

			-- if no base pose kf exists at time 0, create one now
			if frame ~= 0 and trackData[0] == nil then
				if GetFFlagFacialAnimationSupport() then
					AnimationData.addDefaultKeyframe(track, 0, trackType)
				else
					AnimationData.addKeyframe(track, 0, CFrame.new())
				end
			end

			store:dispatch(UpdateAnimationData(newData))

			if analytics then
				analytics:report("onAddKeyframe", trackName, frame)
			end
		end
	end
end

if GetFFlagFacialAnimationSupport() then
	return function(instanceName, trackName, trackType, frame, value, analytics)
		return wrappee(instanceName, trackName, trackType, frame, value, analytics)
	end
else
	return function(instanceName, trackName, frame, value, analytics)
		return wrappee(instanceName, trackName, nil, frame, value, analytics)
	end
end
