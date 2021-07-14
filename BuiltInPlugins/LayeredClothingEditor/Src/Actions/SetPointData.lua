--[[
	Rbf point data for each deformer. Store positional information and face indices for each point.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(pointData)
	return {
		pointData = pointData,
	}
end)