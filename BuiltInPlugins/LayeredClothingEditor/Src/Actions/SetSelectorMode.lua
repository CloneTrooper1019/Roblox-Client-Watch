--[[
	Stores data to decide which instanceSelector using now
	selectorMode's value is defined in Constants as SELECTOR_MODE
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectorMode)
	return {
		selectorMode = selectorMode,
	}
end)