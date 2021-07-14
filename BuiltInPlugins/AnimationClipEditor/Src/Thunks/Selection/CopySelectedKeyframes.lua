--[[
	Copies all keyframes from the current selection to the clipboard.
]]

local StudioService = game:GetService("StudioService")

local Plugin = script.Parent.Parent.Parent.Parent

local deepCopy = require(Plugin.Src.Util.deepCopy)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local SetClipboard = require(Plugin.Src.Actions.SetClipboard)
local Constants = require(Plugin.Src.Util.Constants)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

return function()
	return function(store)
		local state = store:getState()
		local selectedKeyframes = state.Status.SelectedKeyframes
		local animationData = state.AnimationData
		if not (animationData and selectedKeyframes) then
			return
		end

		local clipboard = {}

		for instanceName, instance in pairs(selectedKeyframes) do
			if animationData.Instances[instanceName] then
				clipboard[instanceName] = {}
				for trackName, keyframes in pairs(instance) do
					if animationData.Instances[instanceName].Tracks[trackName] then
						local track = animationData.Instances[instanceName].Tracks[trackName]
						clipboard[instanceName][trackName] = GetFFlagFacialAnimationSupport() and {
							Type = track.Type,
							Data = {},
						} or {}
						for keyframe, _ in pairs(keyframes) do
							local data = track.Data[keyframe]
							if GetFFlagFacialAnimationSupport() then
								clipboard[instanceName][trackName].Data[keyframe] = deepCopy(data)
							else
								clipboard[instanceName][trackName][keyframe] = deepCopy(data)
							end
						end
					end
				end
			end
		end

		-- Clear the Studio clipboard if the Animation Editor has copied keyframes.
		-- This prevents weird overlap between multiple copy and paste logics.
		if not isEmpty(clipboard) then
			StudioService:CopyToClipboard("")
		end

		store:dispatch(SetClipboard(clipboard, Constants.CLIPBOARD_TYPE.Keyframes))
	end
end