local CollectionService = game:GetService("CollectionService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RigUtils = require(Plugin.SrcDeprecated.Util.RigUtils)
local Constants = require(Plugin.SrcDeprecated.Util.Constants)

local SetIKEnabled = require(Plugin.SrcDeprecated.Actions.SetIKEnabled)
local SetIKMode = require(Plugin.SrcDeprecated.Actions.SetIKMode)
local SetShowTree = require(Plugin.SrcDeprecated.Actions.SetShowTree)
local SetPinnedParts = require(Plugin.SrcDeprecated.Actions.SetPinnedParts)

local SetClipboard = require(Plugin.SrcDeprecated.Actions.SetClipboard)
local ReleaseEditor = require(Plugin.SrcDeprecated.Thunks.ReleaseEditor)
local AttachEditor = require(Plugin.SrcDeprecated.Thunks.AttachEditor)
local SetRootInstance = require(Plugin.SrcDeprecated.Actions.SetRootInstance)
local SetAnimationData = require(Plugin.SrcDeprecated.Actions.SetAnimationData)
local SetStartingPose = require(Plugin.SrcDeprecated.Actions.SetStartingPose)
local LoadKeyframeSequence = require(Plugin.SrcDeprecated.Thunks.Exporting.LoadKeyframeSequence)

return function(rootInstance)
	return function(store)
		store:dispatch(ReleaseEditor())

		--reset IK
		store:dispatch(SetPinnedParts({}))
		store:dispatch(SetShowTree(false))
		store:dispatch(SetIKEnabled(false))

		local canUseIK, emptyR15 = RigUtils.canUseIK(rootInstance)
		store:dispatch(SetIKMode(emptyR15 and Constants.IK_MODE.BodyPart or Constants.IK_MODE.FullBody))

		store:dispatch(SetRootInstance(rootInstance))

		if canUseIK and emptyR15 then
			local pose = RigUtils.getPoseCFrames(rootInstance)
			store:dispatch(SetStartingPose(pose))
		else
			store:dispatch(SetStartingPose(Roact.None))
		end

		-- If there is an animation we can load, load it
		local animSaves = RigUtils.getAnimSaves(rootInstance)
		if #animSaves > 0 then
			table.sort(animSaves, function(anim1, anim2)
				local tags1 = CollectionService:GetTags(anim1)
				local tags2 = CollectionService:GetTags(anim2)
				local timestamp1 = tags1[1] and tonumber(tags1[1])
				local timestamp2 = tags2[1] and tonumber(tags2[1])

				if not timestamp1 and not timestamp2 then
					return anim1.Name < anim2.Name
				elseif timestamp1 and not timestamp2 then
					return true
				elseif timestamp2 and not timestamp1 then
					return false
				else
					return timestamp1 > timestamp2
				end
			end)
			store:dispatch(LoadKeyframeSequence(animSaves[1].Name))
		else
			store:dispatch(SetAnimationData(nil))
		end

		store:dispatch(SetClipboard({}))
		store:dispatch(AttachEditor())
	end
end