local Plugin = script.Parent.Parent.Parent

local SetScrollZoom = require(Plugin.Src.Actions.SetScrollZoom)
local AnimationData = require(Plugin.Src.Util.AnimationData)
local Constants = require(Plugin.Src.Util.Constants)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)
local SetAnimationData = require(Plugin.Src.Actions.SetAnimationData)
local StepAnimation = require(Plugin.Src.Thunks.Playback.StepAnimation)
local SetNotification = require(Plugin.Src.Actions.SetNotification)
local UpdateEditingLength = require(Plugin.Src.Thunks.UpdateEditingLength)

return function(animationData)
	return function(store)
		local state = store:getState()

		if not animationData then
			return
		end

		if not animationData.Metadata then
			store:dispatch(SetAnimationData(animationData))
			return
		end

		local scroll = state.Status.Scroll
		local zoom = state.Status.Zoom
		local playhead = state.Status.Playhead
		local editingLength = state.Status.EditingLength

		local startFrame = animationData.Metadata.StartFrame
		local range = TrackUtils.getZoomRange(animationData, scroll, zoom, editingLength)

		local removed = AnimationData.removeExtraKeyframes(animationData)
		if removed then
			store:dispatch(SetNotification("ClippedWarning", true))
		end

		AnimationData.setEndFrame(animationData)
		local newEndFrame = animationData.Metadata.EndFrame

		for _, frame in ipairs(animationData.Events.Keyframes) do
			if frame > newEndFrame then
				animationData.Metadata.EndFrame = frame
				newEndFrame = animationData.Metadata.EndFrame
			end
		end

		-- Legacy keyframe renaming support: Remove any keyframe name
		-- labels that are attached to nonexistent keyframes
		AnimationData.validateKeyframeNames(animationData)

		store:dispatch(SetAnimationData(animationData))

		if startFrame ~= newEndFrame then
			playhead = math.clamp(playhead, startFrame, newEndFrame)
		end
		store:dispatch(StepAnimation(playhead))

		local length = newEndFrame - startFrame

		-- Adjust the timeline length if the animation extends past the visible area.
		-- Adjust the zoom level so that the timeline does not zoom out when it is adjusted.
		if length > editingLength then
			store:dispatch(UpdateEditingLength(length))
			local lengthWithPadding = math.ceil(length * Constants.LENGTH_PADDING)
			local rangeLength = range.End - range.Start

			scroll = 0
			if lengthWithPadding ~= rangeLength then
				scroll = math.clamp((range.Start - startFrame) / (lengthWithPadding - rangeLength), 0, 1)
			end
			zoom = 1 - math.clamp(rangeLength / lengthWithPadding, 0, 1)

			store:dispatch(SetScrollZoom(scroll, zoom))
		end
	end
end