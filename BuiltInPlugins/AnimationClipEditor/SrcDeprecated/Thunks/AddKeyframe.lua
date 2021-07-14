--[[
	Adds a single keyframe at the given track and frame.
	Sets the keyframe's value to the given value.
]]
local Plugin = script.Parent.Parent.Parent

local deepCopy = require(Plugin.SrcDeprecated.Util.deepCopy)
local AnimationData = require(Plugin.SrcDeprecated.Util.AnimationData)
local AddTrack = require(Plugin.SrcDeprecated.Thunks.AddTrack)
local UpdateAnimationData = require(Plugin.SrcDeprecated.Thunks.UpdateAnimationData)

return function(instanceName, trackName, frame, value)
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
			store:dispatch(AddTrack(instanceName, trackName))
			AnimationData.addTrack(tracks, trackName)
		end
		local track = tracks[trackName]
		local trackData = track.Data

		if trackData[frame] == nil then
			AnimationData.addKeyframe(track, frame, value)

			-- if no base pose kf exists at time 0, create one now
			if frame ~= 0 and trackData[0] == nil then
				AnimationData.addKeyframe(track, 0, CFrame.new())
			end

			store:dispatch(UpdateAnimationData(newData))

			if state.Analytics then
				state.Analytics:onAddKeyframe(trackName, frame)
			end
		end
	end
end