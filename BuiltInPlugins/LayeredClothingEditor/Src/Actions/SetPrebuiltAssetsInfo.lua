--[[
	Stores data for prebuilt assets that can be selected from the preview grid
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(prebuiltAssetsInfo)
	return {
		prebuiltAssetsInfo = prebuiltAssetsInfo,
	}
end)