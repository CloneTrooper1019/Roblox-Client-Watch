--[[
	Resets the Animation Editor state and loads a new animation.
]]

local Plugin = script.Parent.Parent.Parent
local isEmpty = require(Plugin.SrcDeprecated.Util.isEmpty)
local AnimationData = require(Plugin.SrcDeprecated.Util.AnimationData)

local AddTrack = require(Plugin.SrcDeprecated.Thunks.AddTrack)
local SortAndSetTracks = require(Plugin.SrcDeprecated.Thunks.SortAndSetTracks)
local SetPast = require(Plugin.SrcDeprecated.Actions.SetPast)
local SetFuture = require(Plugin.SrcDeprecated.Actions.SetFuture)
local StepAnimation = require(Plugin.SrcDeprecated.Thunks.Playback.StepAnimation)
local SetSelectedKeyframes = require(Plugin.SrcDeprecated.Actions.SetSelectedKeyframes)
local SetClipboard = require(Plugin.SrcDeprecated.Actions.SetClipboard)
local UpdateAnimationData = require(Plugin.SrcDeprecated.Thunks.UpdateAnimationData)
local SetIsDirty = require(Plugin.SrcDeprecated.Actions.SetIsDirty)
local SetNotification = require(Plugin.SrcDeprecated.Actions.SetNotification)
local UpdateEditingLength = require(Plugin.SrcDeprecated.Thunks.UpdateEditingLength)
local SetShowEvents = require(Plugin.SrcDeprecated.Actions.SetShowEvents)

return function(animationData)
	return function(store)
		-- Remove potential change history waypoints
		store:dispatch(SetPast({}))
		store:dispatch(SetFuture({}))

		-- Reset all hanging data
		store:dispatch(SetSelectedKeyframes({}))
		store:dispatch(SortAndSetTracks({}))

		for instanceName, instance in pairs(animationData.Instances) do
			for trackName, _ in pairs(instance.Tracks) do
				store:dispatch(AddTrack(instanceName, trackName))
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