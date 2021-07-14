--[[
	Sets which assets are selected from the preview panel's grid
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectedAssets)
	return {
		selectedAssets = selectedAssets,
	}
end)