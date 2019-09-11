local CollectionService = game:GetService("CollectionService")

local Plugin = script.Parent.Parent.Parent
local RigUtils = require(Plugin.Src.Util.RigUtils)
local Constants = require(Plugin.Src.Util.Constants)

local SetIKEnabled = require(Plugin.Src.Actions.SetIKEnabled)
local SetIKMode = require(Plugin.Src.Actions.SetIKMode)
local SetShowTree = require(Plugin.Src.Actions.SetShowTree)
local SetPinnedParts = require(Plugin.Src.Actions.SetPinnedParts)

local ReleaseEditor = require(Plugin.Src.Thunks.ReleaseEditor)
local AttachEditor = require(Plugin.Src.Thunks.AttachEditor)
local SetRootInstance = require(Plugin.Src.Actions.SetRootInstance)
local SetAnimationData = require(Plugin.Src.Actions.SetAnimationData)
local LoadKeyframeSequence = require(Plugin.Src.Thunks.Exporting.LoadKeyframeSequence)

return function(rootInstance)
	return function(store)
		store:dispatch(ReleaseEditor())

		--reset IK
		store:dispatch(SetPinnedParts({}))
		store:dispatch(SetShowTree(false))
		store:dispatch(SetIKEnabled(false))

		local _, emptyR15 = RigUtils.canUseIK(rootInstance)
		store:dispatch(SetIKMode(emptyR15 and Constants.IK_MODE.BodyPart or Constants.IK_MODE.FullBody))

		store:dispatch(SetRootInstance(rootInstance))

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

		store:dispatch(AttachEditor())
	end
end