--[[
	Templates used to create AnimationData elements.
]]

local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)

local Templates = {}

function Templates.animationData()
	return {
		-- TODO: AVBURST-327 Update placeholder Metadata values
		-- when we know how these values will work for Animations
		-- and what their true defaults should be
		Metadata = {
			Name = "",
			StartFrame = 0,
			EndFrame = 0,
			Looping = false,
			Priority = Enum.AnimationPriority.Core,
			FrameRate = 30,
		},
		Events = {
			NamedKeyframes = {},
			Keyframes = {},
			Data = {},
		},
		Instances = {
			Root = {
				Type = nil,
				Tracks = {},
			},
		},
	}
end

function Templates.instance()
	return {
		Type = nil,
		Tracks = {},
	}
end

function Templates.track(trackType)
	return {
		Type = trackType,
		Keyframes = {},
		Data = {},
	}
end

function Templates.trackListEntry()
	return {
		Name = "",
		Depth = 0,
		Expanded = false,
		Selected = false,
		Type = Constants.TRACK_TYPES.CFrame,
	}
end

function Templates.keyframe()
	return {
		Value = nil,
		EasingStyle = Enum.PoseEasingStyle.Linear,
		EasingDirection = Enum.PoseEasingDirection.In,
	}
end

return Templates