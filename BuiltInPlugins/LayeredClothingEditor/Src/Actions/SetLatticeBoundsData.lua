--[[
	Sets bounding box data for each deformer's lattice
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(latticeBoundsData)
	return {
		latticeBoundsData = latticeBoundsData,
	}
end)