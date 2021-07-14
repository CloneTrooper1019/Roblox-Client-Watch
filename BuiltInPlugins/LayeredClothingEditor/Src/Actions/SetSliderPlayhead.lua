--[[
	Used to set the playhead's location by slider,
	if its value >= 0, means the animation is controlled by slider now,
	then its value should override playhead value
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(sliderPlayhead)
	return {
		sliderPlayhead = sliderPlayhead,
	}
end)