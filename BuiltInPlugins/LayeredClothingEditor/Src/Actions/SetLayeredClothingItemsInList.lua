--[[
	Stores data for items that can be selected from selection list
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(layeredClothingItemsInList)
	return {
		layeredClothingItemsInList = layeredClothingItemsInList,
	}
end)