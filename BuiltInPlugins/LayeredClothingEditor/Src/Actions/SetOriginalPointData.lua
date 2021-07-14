--[[
	Rbf point data for each deformer before any edits have been made.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(originalPointData)
	return {
		originalPointData = originalPointData,
	}
end)