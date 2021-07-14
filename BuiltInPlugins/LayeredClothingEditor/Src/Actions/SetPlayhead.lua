--[[
	Used to set the playhead's location.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(playhead)
	return {
		playhead = playhead,
	}
end)