--[[
	Keeps track if playback is currently running in the Editor.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(isPlaying)
	return {
		isPlaying = isPlaying,
	}
end)