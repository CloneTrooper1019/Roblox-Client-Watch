--[[
	For Lattice Tool: keeps track of all control points on lattice that
	were selected by the user.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectedControlPoints)
	return {
		selectedControlPoints = selectedControlPoints,
	}
end)