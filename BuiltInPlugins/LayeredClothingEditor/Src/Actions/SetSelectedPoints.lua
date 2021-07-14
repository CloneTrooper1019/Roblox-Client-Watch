--[[
	For Point Tool: represents all rbf points selected, either via clicking or from
	soft selection.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectedPoints)
	return {
		selectedPoints = selectedPoints,
	}
end)