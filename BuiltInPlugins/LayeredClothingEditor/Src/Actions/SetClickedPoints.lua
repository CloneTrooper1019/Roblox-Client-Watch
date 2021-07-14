--[[
	For Point Tool: keeps track of points clicked on directly by user
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(clickedPoints)
	return {
		clickedPoints = clickedPoints,
	}
end)