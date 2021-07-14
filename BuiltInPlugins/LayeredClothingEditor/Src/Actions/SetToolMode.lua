--[[
	Sets current tool being used in editor: Lattice, Point, Reset
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(toolMode)
	return {
		toolMode = toolMode,
	}
end)