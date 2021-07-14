--[[
	Sets which tabs are selected in the preview panel
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectedTab)
	return {
		selectedTab = selectedTab,
	}
end)