--[[
	When the plugin is activated, return everything that is controlled
	by the AnimationClip editor to its pose.
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local StudioService = game:GetService("StudioService")

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local StepAnimation = require(Plugin.Src.Thunks.Playback.StepAnimation)
local SetRootInstance = require(Plugin.Src.Actions.SetRootInstance)
local SetAnimationData = require(Plugin.Src.Actions.SetAnimationData)
local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local AddTrack = require(Plugin.Src.Thunks.AddTrack)
local SortAndSetTracks = require(Plugin.Src.Thunks.SortAndSetTracks)
local SetActive = require(Plugin.Src.Actions.SetActive)
local RigUtils = require(Plugin.Src.Util.RigUtils)
local DisableRigAutofocus = require(Plugin.LuaFlags.GetFFlagDisableRigAutofocus)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

return function(analytics)
	return function(store)
		local state = store:getState()
		store:dispatch(SetActive(true))
		local rootInstance = state.Status.RootInstance
		local animationData = state.AnimationData

		local playhead = state.Status.Playhead
		local visualizeBones = state.Status.VisualizeBones

		ChangeHistoryService:SetEnabled(false)
		StudioService:CopyToClipboard("")

		-- If the old animation target is gone, reset to the start screen.
		-- User deleted it or moved it into storage when the plugin was closed.
		if (rootInstance == nil or rootInstance:FindFirstAncestorOfClass("Workspace") == nil)
			or (rootInstance and RigUtils.rigHasErrors(rootInstance)) then
			store:dispatch(SetRootInstance(Cryo.None))
			store:dispatch(SortAndSetTracks({}))
			store:dispatch(SetSelectedKeyframes({}))
			store:dispatch(SetAnimationData(nil))
			return
		end

		if not DisableRigAutofocus() then
			RigUtils.focusCamera(rootInstance)
		end

		-- Make sure the tracks are synchronized in case the user renamed a part.
		if animationData then
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
		end

		RigUtils.clearMicrobones()
		if rootInstance and not animationData then
			RigUtils.updateMicrobones(rootInstance, visualizeBones)
		end
		store:dispatch(StepAnimation(playhead))
	end
end