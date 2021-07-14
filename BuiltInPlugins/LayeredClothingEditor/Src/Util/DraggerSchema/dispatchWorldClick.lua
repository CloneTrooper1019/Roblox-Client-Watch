return function(draggerContext, draggerToolModel, event)
	local Plugin = script.Parent.Parent.Parent.Parent
	local Constants = require(Plugin.Src.Util.Constants)
	local ToolUtil = require(Plugin.Src.Util.ToolUtil)

	if not event.ClickedItem and ToolUtil:isDraggerPointMode(draggerContext) or ToolUtil:isDraggerLatticeMode(draggerContext) then
		return Constants.DRAGGER_STATES.DragSelecting
	else
		return Constants.DRAGGER_STATES.Ready
	end
end