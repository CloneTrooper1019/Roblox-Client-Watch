--[[
	Resets the Animation Editor state and loads a new animation.
]]

local Plugin = script.Parent.Parent.Parent
local isEmpty = require(Plugin.Src.Util.isEmpty)
local AnimationData = require(Plugin.Src.Util.AnimationData)

local AddTrack = require(Plugin.Src.Thunks.AddTrack)
local SortAndSetTracks = require(Plugin.Src.Thunks.SortAndSetTracks)
local SetPast = require(Plugin.Src.Actions.SetPast)
local SetFuture = require(Plugin.Src.Actions.SetFuture)
local StepAnimation = require(Plugin.Src.Thunks.Playback.StepAnimation)
local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local UpdateAnimationData = require(Plugin.Src.Thunks.UpdateAnimationData)
local SetIsDirty = require(Plugin.Src.Actions.SetIsDirty)
local SetNotification = require(Plugin.Src.Actions.SetNotification)
local UpdateEditingLength = require(Plugin.Src.Thunks.UpdateEditingLength)
local SetShowEvents = require(Plugin.Src.Actions.SetShowEvents)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

return function(animationData, analytics)
	return function(store)
		-- Remove potential change history waypoints
		store:dispatch(SetPast({}))
		store:dispatch(SetFuture({}))

		-- Reset all hanging data
		store:dispatch(SetSelectedKeyframes({}))
		store:dispatch(SortAndSetTracks({}))

		for instanceName, instance in pairs(animationData.Instances) do
			for trackName, track in pairs(instance.Tracks) do
				if GetFFlagFacialAnimationSupport() then
					store:dispatch(AddTrack(instanceName, trackName, track.Type, analytics))
				else
					store:dispatch(AddTrack(instanceName, trackName, analytics))
				end
			end
		end

		store:dispatch(UpdateAnimationData(animationData))
		store:dispatch(StepAnimation(0))
		store:dispatch(SetIsDirty(true))
		store:dispatch(UpdateEditingLength(animationData.Metadata.EndFrame))
		store:dispatch(SetShowEvents(not isEmpty(animationData.Events.Keyframes)))

		local isQuantized = AnimationData.isQuantized(animationData)
		store:dispatch(SetNotification("QuantizeWarning", not isQuantized))
	end
end
