--[[
	Sets bounding box data for each deformer's rbf point cloud
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(boundsData)
	return {
		boundsData = boundsData,
	}
end)