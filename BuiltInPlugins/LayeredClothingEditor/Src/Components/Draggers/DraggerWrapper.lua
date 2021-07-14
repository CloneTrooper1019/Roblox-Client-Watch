--[[
	Wrapper around DraggerToolComponent for the editor. Maps necesssary data from store to dragger context.
	Studio dragger functionality is overriden to support dragging vertices while this component is active.
	Sets up it's own undo/redo stack since manipulating vertices isn't supported by studio undo/redo.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local SignalsContext = require(Plugin.Src.Context.Signals)
local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local LayeredClothingDragger = require(Plugin.Src.Components.Draggers.LayeredClothingDragger)

local TransformPoints = require(Plugin.Src.Thunks.TransformPoints)
local TransformLatticePoints = require(Plugin.Src.Thunks.TransformLatticePoints)
local AddWaypoint = require(Plugin.Src.Thunks.AddWaypoint)
local SetHovered = require(Plugin.Src.Actions.SetHovered)
local SetDraggerType = require(Plugin.Src.Actions.SetDraggerType)
local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)
local SetSelectedControlPoints = require(Plugin.Src.Actions.SetSelectedControlPoints)
local CycleHandles = require(Plugin.Src.Thunks.CycleHandles)
local Undo = require(Plugin.Src.Thunks.Undo)
local Redo = require(Plugin.Src.Thunks.Redo)

local DraggerFramework = Plugin.Packages.DraggerFramework
local DraggerContext_PluginImpl = require(DraggerFramework.Implementation.DraggerContext_PluginImpl)
local Constants = require(Plugin.Src.Util.Constants)
local delayToNextFrame = require(Plugin.Src.Util.delayToNextFrame)
local DraggerSchema = require(Plugin.Src.Util.DraggerSchema.DraggerSchema)

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local DraggerWrapper = Roact.PureComponent:extend("DraggerWrapper")

local function mapDraggerContextToProps(context, selection, props, editingItemContext)
	context.toolMode = props.ToolMode
	context.pointData = props.PointData
	context.boundsData = props.BoundsData
	context.selectedLattice = props.SelectedLattice
	context.latticeData = props.LatticeData
	context.latticeBoundsData = props.LatticeBoundsData
	context.editingCage = props.EditingCage
	context.editingItem = editingItemContext:getItem()
	context.transformPoints = props.TransformPoints
	context.transformLatticePoints = props.TransformLatticePoints
	context.addWaypoint = props.AddWaypoint
	context.selectRbfPoint = props.SelectRbfPoint
	context.setSelectedControlPoints = props.SetSelectedControlPoints
	context.setHovered = props.SetHovered

	selection.toolMode = props.ToolMode
	selection.clickedPoints = props.ClickedPoints
	selection.selectedControlPoints = props.SelectedControlPoints
	selection.selectRbfPoint = props.SelectRbfPoint
	selection.setSelectedControlPoints = props.SetSelectedControlPoints
end

function DraggerWrapper:didMount()
	local props = self.props

	local plugin = props.Plugin:get()
	plugin:Activate(true)

	local selectionSignal = props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged)
	local toolChangedSignal = props.Signals:get(Constants.SIGNAL_KEYS.ToolChanged)

	self.selection = DraggerSchema.Selection.new(selectionSignal)
	self.draggerContext = DraggerContext_PluginImpl.new(plugin, game, settings(), self.selection)
	self.draggerContext.ToolChangedSignal = toolChangedSignal
	self.draggerContext.SelectedPointMeta = {
		__eq = function(p1, p2)
			return p1.Deformer == p2.Deformer and
				p1.Index == p2.Index
		end,
	}
	self.draggerContext.selectedControlPointMeta = {
		__eq = function(p1, p2)
			return p1.Deformer == p2.Deformer and
				p1.ID == p2.ID and
				p1.GridPosition.X == p2.GridPosition.X and
				p1.GridPosition.Y == p2.GridPosition.Y and
				p1.GridPosition.Z == p2.GridPosition.Z
		end
	}

	local CycleHandlesAction = props.PluginActions:get("CycleHandles")
	if CycleHandlesAction then
		CycleHandlesAction.Enabled = true
		self.changeDraggerHandle = CycleHandlesAction.Triggered:Connect(function()
			props.CycleHandles()
		end)
	end

	mapDraggerContextToProps(self.draggerContext, self.selection, self.props, self.props.EditingItemContext)

	-- If we deactivated because the user selected a ribbon tool,
	-- it is likely they were trying to use move/rotate in the editor.
	-- Use it to switch the current tool.
	self.onToolSelected = function(tool)
		-- have to check specifically for these because Enum.RibbonTool has other items we do not want
		if tool == Enum.RibbonTool.Select
			or tool == Enum.RibbonTool.Rotate
			or tool == Enum.RibbonTool.Move
			or tool == Enum.RibbonTool.Scale then

			delayToNextFrame(function()
				plugin:Activate(true)
			end)
			self.props.SetDraggerType(tool)
			return true
		end
	end

	self.deactivationListener = plugin.Deactivation:Connect(function()
		local tool = plugin:GetSelectedRibbonTool()
		if tool ~= Enum.RibbonTool.None and next(game:GetService("Selection"):Get()) == nil then
			if self.onToolSelected(tool) then
				return
			end
		end
	end)

	local undoAction = props.PluginActions:get("Undo")
	if undoAction then
		undoAction.Enabled = true
		self.undoHandle = undoAction.Triggered:Connect(function()
			props.Undo()
			selectionSignal:Fire()
		end)
	end

	local redoAction = props.PluginActions:get("Redo")
	if redoAction then
		redoAction.Enabled = true
		self.redoHandle = redoAction.Triggered:Connect(function()
			props.Redo()
			selectionSignal:Fire()
		end)
	end

	ChangeHistoryService:SetEnabled(false)

	self:setState({temp = {}})
end

function DraggerWrapper:willUpdate(nextProps)
	local selectionSignal = self.props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged)
	mapDraggerContextToProps(self.draggerContext, self.selection, nextProps, self.props.EditingItemContext)
	if nextProps.ClickedPoints ~= self.props.ClickedPoints or nextProps.SelectedControlPoints ~= self.props.SelectedControlPoints then
		selectionSignal:Fire()
	end
end

function DraggerWrapper:render()
	local props = self.props

	local draggerType = props.DraggerType
	local mouse = props.Mouse:get()

	if not self.draggerContext then
		return nil
	end

	return Roact.createElement(LayeredClothingDragger, {
		Context = self.draggerContext,
		DraggerType = draggerType,
		Mouse = mouse,
	})
end

function DraggerWrapper:willUnmount()
	local props = self.props

	local undoAction = props.PluginActions:get("Undo")
	local redoAction = props.PluginActions:get("Redo")

	if undoAction then
		undoAction.Enabled = false
	end

	if redoAction then
		redoAction.Enabled = false
	end

	if self.deactivationListener then
		self.deactivationListener:Disconnect()
	end

	if self.changeDraggerHandle then
		self.changeDraggerHandle:Disconnect()
	end

	if self.undoHandle then
		self.undoHandle:Disconnect()
	end

	if self.redoHandle then
		self.redoHandle:Disconnect()
	end

	ChangeHistoryService:SetEnabled(true)
end

local function mapStateToProps(state, props)
	local status = state.status
	local cageData = state.cageData
	local pointTool = state.pointTool
	local latticeTool = state.latticeTool
	local selectItem = state.selectItem

	return {
		DraggerType = status.draggerType,
		ToolMode = status.toolMode,
		PointData = cageData.pointData,
		BoundsData = cageData.boundsData,
		SelectedLattice = latticeTool.selectedLattice,
		LatticeData = latticeTool.latticeData,
		LatticeBoundsData = latticeTool.latticeBoundsData,
		EditingCage = selectItem.editingCage,
		EditingItem = selectItem.editingItem,
		ClickedPoints = pointTool.clickedPoints,
		SelectedControlPoints = status.selectedControlPoints
	}
end

local function mapDispatchToProps(dispatch)
	return {
		CycleHandles = function()
			dispatch(CycleHandles())
		end,

		TransformPoints = function(baseData, transformData, localSpace)
			dispatch(TransformPoints(baseData, transformData, localSpace))
		end,

		TransformLatticePoints = function(baseData, baseLatticeData, transformData, localSpace)
			dispatch(TransformLatticePoints(baseData, baseLatticeData, transformData, localSpace))
		end,

		SetHovered = function(hovered)
			dispatch(SetHovered(hovered))
		end,

		AddWaypoint = function()
			dispatch(AddWaypoint())
		end,

		SelectRbfPoint = function(selection)
			dispatch(SelectRbfPoint(selection))
		end,

		SetDraggerType = function(type)
			dispatch(SetDraggerType(type))
		end,

		SetSelectedControlPoints = function(selection)
			dispatch(SetSelectedControlPoints(selection))
		end,

		Undo = function()
			dispatch(Undo())
		end,

		Redo = function()
			dispatch(Redo())
		end,
	}
end

ContextServices.mapToProps(DraggerWrapper,{
	Plugin = ContextServices.Plugin,
	PluginActions = ContextServices.PluginActions,
	Signals = SignalsContext,
	EditingItemContext = EditingItemContext,
	Mouse = ContextServices.Mouse,
})

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(DraggerWrapper)