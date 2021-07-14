local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local Constants = require(Plugin.Src.Util.Constants)

return Rodux.createReducer({
	toolMode = Constants.TOOL_MODE.None,
	selectedControlPoints = {},
	draggerType = Enum.RibbonTool.Select
}, {
	SetToolMode = function(state, action)
		return Cryo.Dictionary.join(state, {
			toolMode = action.toolMode,
		})
	end,
	SetSelectedControlPoints = function(state, action)
		return Cryo.Dictionary.join(state, {
			selectedControlPoints = action.selectedControlPoints,
		})
	end,
	SetDraggerType = function(state, action)
		return Cryo.Dictionary.join(state, {
			draggerType = action.draggerType,
		})
	end,
	SetHovered = function(state, action)
		return Cryo.Dictionary.join(state, {
			hoveredPoint = action.hoveredPoint,
		})
	end,
})