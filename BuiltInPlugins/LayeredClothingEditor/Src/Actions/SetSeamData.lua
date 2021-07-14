--[[
	Stores what a seam rbf point's corresponding point is on another deformer
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(seamData)
	return {
		seamData = seamData,
	}
end)