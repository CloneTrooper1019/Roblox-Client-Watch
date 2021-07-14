--[[
	Stores data for the layered clothing item that is editing now.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(editingItem)
	return {
		editingItem = editingItem,
	}
end)