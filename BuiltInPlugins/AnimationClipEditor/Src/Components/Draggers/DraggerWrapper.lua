local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Selection = game:GetService("Selection")

local SignalsContext = require(Plugin.Src.Context.Signals)

local AnimationClipEditorDragger = require(Plugin.Src.Components.Draggers.AnimationClipEditorDragger)

local DraggerFramework = Plugin.Packages.DraggerFramework
local DraggerContext_PluginImpl = require(DraggerFramework.Implementation.DraggerContext_PluginImpl)
local Constants = require(Plugin.Src.Util.Constants)
local ValueChanged = require(Plugin.Src.Thunks.ValueChanged)
local DraggerSchema = require(Plugin.Src.Util.DraggerSchema.DraggerSchema)
local SetSelectedTrackInstances = require(Plugin.Src.Actions.SetSelectedTrackInstances)
local SetSelectedTracks = require(Plugin.Src.Actions.SetSelectedTracks)
local AddWaypoint = require(Plugin.Src.Thunks.History.AddWaypoint)

local GetFFlagNoValueChangeDuringPlayback = require(Plugin.LuaFlags.GetFFlagNoValueChangeDuringPlayback)
local GetFFlagRevertExplorerSelection = require(Plugin.LuaFlags.GetFFlagRevertExplorerSelection)
local GetFFlagCreateSelectionBox = require(Plugin.LuaFlags.GetFFlagCreateSelectionBox)
local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local DraggerWrapper = Roact.PureComponent:extend("DraggerWrapper")

function DraggerWrapper:init()
	self.state = {
		selection = nil,
	}
end

function DraggerWrapper:willUpdate(nextProps)
	local props = self.props
	if self.selection and props.SelectedTrackInstances ~= nextProps.SelectedTrackInstances then
		if GetFFlagRevertExplorerSelection() then
			self.selection.selectedTrackInstances = nextProps.SelectedTrackInstances
		end
		if not GetFFlagCreateSelectionBox() then
			Selection:Set(nextProps.SelectedTrackInstances)
		end
		local selectionSignal = self.props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged)
		selectionSignal:Fire()
	end
end

local function mapDraggerContextToProps(draggerContext, props)
	draggerContext.RootInstance = props.RootInstance
	draggerContext.IKMode = props.IKMode
	draggerContext.StartingPose = props.StartingPose
	draggerContext.PinnedParts = props.PinnedParts
	draggerContext.IKEnabled = props.IKEnabled
	draggerContext.Tool = props.Tool
	draggerContext.OnManipulateJoints = function(instanceName, values)
		if (GetFFlagNoValueChangeDuringPlayback() and props.IsPlaying) then
			return
		end

		for trackName, value in pairs(values) do
			if GetFFlagFacialAnimationSupport() then
				props.ValueChanged(instanceName, trackName, Constants.TRACK_TYPES.CFrame, props.Playhead, value, props.Analytics)
			else
				props.ValueChanged_deprecated(instanceName, trackName, props.Playhead, value, props.Analytics)
			end
		end
	end
end

local function setUpDraggerContext(props)
	local plugin = props.Plugin:get()

	local selectionSignal = props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged)

	local selection = DraggerSchema.Selection.new(selectionSignal, props.SetSelectedTrackInstances)
	local draggerContext = DraggerContext_PluginImpl.new(plugin, game, settings(), selection)
	draggerContext.AddWaypoint = function()
		props.AddWaypoint()
	end
	return selection, draggerContext
end

function DraggerWrapper:render()
	local props = self.props

	local tool = props.Tool
	local mouse = props.Mouse:get()

	if not self.draggerContext then
		if props.AnimationData ~= nil then
			self.selection, self.draggerContext = setUpDraggerContext(props)
			self:setState({
				selection = self.selection,
			})
		else
			return
		end
	end

	mapDraggerContextToProps(self.draggerContext, props)


	return Roact.createElement(AnimationClipEditorDragger, {
		Context = self.draggerContext,
		Tool = tool,
		Mouse = mouse,
	})
end

local function mapStateToProps(state, props)
	local status = state.Status

	return {
		Tool = state.Status.Tool,
		SelectedTrackInstances = state.Status.SelectedTrackInstances,
		RootInstance = state.Status.RootInstance,
		IKMode = state.Status.IKMode,
		StartingPose = state.Status.StartingPose,
		PinnedParts = state.Status.PinnedParts,
		IKEnabled = state.Status.IKEnabled,
		Playhead = state.Status.Playhead,
		IsPlaying = status.IsPlaying,
		AnimationData = state.AnimationData,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetSelectedTrackInstances = function(tracks)
			local trackNames = {}
			if not GetFFlagRevertExplorerSelection() then
				for index, track in pairs(tracks) do
					trackNames[index] = track.Name
				end
			end
			dispatch(SetSelectedTrackInstances(tracks))
			if not GetFFlagRevertExplorerSelection() then
				dispatch(SetSelectedTracks(trackNames))
			end
		end,

		ValueChanged = function(instanceName, trackName, trackType, frame, value, analytics)
			dispatch(ValueChanged(instanceName, trackName, trackType, frame, value, analytics))
		end,

		-- Remove when GetFFlagFacialAnimationSupport() is retired
		ValueChanged_deprecated = function(instanceName, trackName, frame, value, analytics)
			dispatch(ValueChanged(instanceName, trackName, frame, value, analytics))
		end,

		AddWaypoint = function()
			dispatch(AddWaypoint())
		end,
	}
end

ContextServices.mapToProps(DraggerWrapper,{
	Plugin = ContextServices.Plugin,
	PluginActions = ContextServices.PluginActions,
	Signals = SignalsContext,
	Mouse = ContextServices.Mouse,
	Analytics = ContextServices.Analytics,
})

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(DraggerWrapper)
