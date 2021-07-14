--[[
	Loads a KeyframeSequence animation by the current name
	from the AnimSaves folder.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local RigUtils = require(Plugin.Src.Util.RigUtils)
local LoadAnimationData = require(Plugin.Src.Thunks.LoadAnimationData)
local SetNotification = require(Plugin.Src.Actions.SetNotification)
local SetIsDirty = require(Plugin.Src.Actions.SetIsDirty)

return function(name, analytics)
	return function(store)
		local state = store:getState()
		local rootInstance = state.Status.RootInstance
		if not rootInstance then
			return
		end

		local animSaves = RigUtils.getAnimSavesFolder(rootInstance)
		if animSaves then
			local keyframeSequence = animSaves:FindFirstChild(name)
			if keyframeSequence then
				local newData, numKeyframes, numPoses, numEvents
				local frameRate = RigUtils.calculateFrameRate(keyframeSequence)
				newData, numKeyframes, numPoses, numEvents = RigUtils.fromRigAnimation(
					keyframeSequence, frameRate)
				store:dispatch(LoadAnimationData(newData, analytics))
				store:dispatch(SetNotification("Loaded", name))
				store:dispatch(SetIsDirty(false))

				analytics:report("onLoadAnimation", name, numKeyframes, numPoses, numEvents)
			end
		end
	end
end