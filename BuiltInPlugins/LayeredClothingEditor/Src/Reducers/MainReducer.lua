local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local CageData = require(Plugin.Src.Reducers.CageData)
local LatticeTool = require(Plugin.Src.Reducers.LatticeTool)
local PointTool = require(Plugin.Src.Reducers.PointTool)
local Status = require(Plugin.Src.Reducers.Status)
local PreviewStatus = require(Plugin.Src.Reducers.PreviewStatus)
local SelectItem = require(Plugin.Src.Reducers.SelectItem)
local ControlsPanelBlocker = require(Plugin.Src.Reducers.ControlsPanelBlocker)
local PreviewAssets = require(Plugin.Src.Reducers.PreviewAssets)
local History = require(Plugin.Src.Reducers.History)
local Animation = require(Plugin.Src.Reducers.Animation)

local MainReducer = Rodux.combineReducers({
	cageData = CageData,
	pointTool = PointTool,
	latticeTool = LatticeTool,
	status = Status,
	previewStatus = PreviewStatus,
	selectItem = SelectItem,
	controlsPanelBlocker = ControlsPanelBlocker,
	previewAssets = PreviewAssets,
	history = History,
	animation = Animation,
})

return MainReducer