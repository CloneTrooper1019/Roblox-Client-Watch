--[[
	For Point Tool: Soft Select falloff distance
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(falloff)
	return {
		falloff = falloff,
	}
end)