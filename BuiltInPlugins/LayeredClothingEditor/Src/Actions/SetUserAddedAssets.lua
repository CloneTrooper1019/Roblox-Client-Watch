--[[
	Stores data for assets user has added manually into the prevew tab.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(userAddedAssets)
	return {
		userAddedAssets = userAddedAssets,
	}
end)