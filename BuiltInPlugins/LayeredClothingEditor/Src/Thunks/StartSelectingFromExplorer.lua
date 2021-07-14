local Plugin = script.Parent.Parent.Parent
local SetSelectorMode = require(Plugin.Src.Actions.SetSelectorMode)
local SetControlsPanelBlockerActivity = require(Plugin.Src.Actions.SetControlsPanelBlockerActivity)
local SetControlsPanelBlockerMessage = require(Plugin.Src.Actions.SetControlsPanelBlockerMessage)

return function(selectorMode, message)
	return function(store)
		local Selection = game:GetService("Selection")
		Selection:Set({nil})
		store:dispatch(SetSelectorMode(selectorMode))
		store:dispatch(SetControlsPanelBlockerActivity(true))
		store:dispatch(SetControlsPanelBlockerMessage(message))
	end
end