--[[
	Info about the accessory, like type and bounds.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(accessoryTypeInfo)
	return {
		accessoryTypeInfo = accessoryTypeInfo,
	}
end)