--[[
	Stores data for if controls panel blocker should be active
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(isActive)
	return {
		isActive = isActive,
	}
end)