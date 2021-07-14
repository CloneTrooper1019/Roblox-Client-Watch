--[[
	Sets CFrame of the editing item attachment
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(attachmentPoint)
	return {
		attachmentPoint = attachmentPoint,
	}
end)