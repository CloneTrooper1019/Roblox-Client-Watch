local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local SetSelectorMode = require(Plugin.Src.Actions.SetSelectorMode)
local SetControlsPanelBlockerActivity = require(Plugin.Src.Actions.SetControlsPanelBlockerActivity)
return function(selectItem)
	return function(store)
		store:dispatch(SetSelectorMode(Constants.SELECTOR_MODE.None))
		store:dispatch(SetControlsPanelBlockerActivity(false))
	end
end