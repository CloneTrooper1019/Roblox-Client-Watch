--[[
	Sets animation track length
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(trackLength)
	return {
		trackLength = trackLength,
	}
end)