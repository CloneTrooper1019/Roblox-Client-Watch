--[[
	Stores data for the layered clothing items that are deleted from selection list
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(manuallyHiddenLayeredClothingItems)
	return {
		manuallyHiddenLayeredClothingItems = manuallyHiddenLayeredClothingItems,
	}
end)