--[[
	Prompts the user to select an Animation asset to upload, then
	imports the KeyframeSequence from the Roblox asset id.
]]

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local Plugin = script.Parent.Parent.Parent.Parent
local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local RigUtils = require(Plugin.SrcDeprecated.Util.RigUtils)
local LoadAnimationData = require(Plugin.SrcDeprecated.Thunks.LoadAnimationData)
local SetIsDirty = require(Plugin.SrcDeprecated.Actions.SetIsDirty)

local SetNotification = require(Plugin.SrcDeprecated.Actions.SetNotification)

local GetFFlagAddImportFailureToast = require(Plugin.LuaFlags.GetFFlagAddImportFailureToast)

return function(plugin)
	return function(store)
		local state = store:getState()
		local rootInstance = state.Status.RootInstance
		if not rootInstance then
			return
		end

		local id = plugin:PromptForExistingAssetId("Animation")
		if id and tonumber(id) > 0 then
			local anim
			if GetFFlagAddImportFailureToast() then
				local status = pcall(function()
					anim = KeyframeSequenceProvider:GetKeyframeSequenceById(id, false)
				end)

				if not status then
					store:dispatch(SetNotification("InvalidAnimation", true))
				end

				if not anim then
					return
				end
			else
				anim = KeyframeSequenceProvider:GetKeyframeSequenceById(id, false)
			end

			local frameRate = RigUtils.calculateFrameRate(anim)
			local newData = RigUtils.fromRigAnimation(anim, frameRate)
			newData.Metadata.Name = Constants.DEFAULT_IMPORTED_NAME
			store:dispatch(LoadAnimationData(newData))
			store:dispatch(SetIsDirty(false))

			state.Analytics:onImportAnimation(id)
		end
	end
end