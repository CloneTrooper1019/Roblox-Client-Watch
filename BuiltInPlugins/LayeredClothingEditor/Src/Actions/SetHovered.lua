--[[
	Represents an rbf/control point hovered by the user's mouse
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(hoveredPoint)
	return {
		hoveredPoint = hoveredPoint,
	}
end)