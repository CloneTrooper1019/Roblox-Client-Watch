--[[
	Stores data for the cage that is editing now.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(editingCage)
	return {
		editingCage = editingCage,
	}
end)