--[[
	Sets what manipulation mode the draggers are using (select, move, rotate, scale)
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(draggerType)
	return {
		draggerType = draggerType,
	}
end)