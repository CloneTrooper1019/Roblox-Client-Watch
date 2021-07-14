--[[
	Stores data for what message should be shown on controls panel blocker
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(message)
	return {
		message = message,
	}
end)