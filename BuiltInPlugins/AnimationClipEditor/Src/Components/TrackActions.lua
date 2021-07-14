--[[
	Handles track actions and the track menu.
	When this component renders, it determines which actions should be enabled.
	This allows keyboard shortcuts to work only when they provide meaningful action.
	When the ShowMenu prop is true, this component also spawns a context menu
	to show the actions controlled by this component. Disabled actions will appear
	greyed out in this menu.

	Props:
		bool ShowMenu = Whether to show the context menu.
		function OnMenuOpened() = A callback for when the context menu has successfully opened.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local Framework = Plugin.Packages.Framework
local ContextServices = require(Framework.ContextServices)
local ContextMenu = require(Plugin.Src.Components.ContextMenu)

local KeyframeUtils = require(Plugin.Src.Util.KeyframeUtils)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)

local AddWaypoint = require(Plugin.Src.Thunks.History.AddWaypoint)
local AddKeyframe = require(Plugin.Src.Thunks.AddKeyframe)
local DeleteTrack = require(Plugin.Src.Thunks.DeleteTrack)
local SetRightClickContextInfo = require(Plugin.Src.Actions.SetRightClickContextInfo)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local TrackActions = Roact.PureComponent:extend("TrackActions")

function TrackActions:makeMenuActions()
	local pluginActions = self.props.PluginActions
	local actions = {
		pluginActions:get("AddKeyframe"),
		pluginActions:get("DeleteTrack"),
	}

	return actions
end

function TrackActions:addAction(action, func)
	if action then
		action.Enabled = false
		table.insert(self.Actions, action)

		table.insert(self.Connections, action.Triggered:Connect(func))
	end
end

function TrackActions:didMount()
	local actions = self.props.PluginActions
	self.Actions = {}
	self.Connections = {}

	self:addAction(actions:get("DeleteTrack"), function()
		local props = self.props
		local trackName = props.TrackName
		props.DeleteTrack(trackName, props.Analytics)
	end)

	self:addAction(actions:get("AddKeyframe"), function()
		local props = self.props
		local playhead = props.Playhead
		local trackName = props.TrackName
		local trackType = props.TrackType
		local instanceName = props.InstanceName

		if instanceName and trackName then
			local instance = props.AnimationData.Instances[instanceName]
			local track = instance.Tracks[trackName]
			local newValue
			if track and track.Keyframes then
				newValue = KeyframeUtils:getValue(track, playhead)
			else
				if GetFFlagFacialAnimationSupport() then
					newValue = TrackUtils.getDefaultValueFromType(trackType)
				else
					newValue = TrackUtils.getDefaultValue(track)
				end
			end
			if GetFFlagFacialAnimationSupport() then
				props.AddKeyframe(instanceName, trackName, trackType, playhead, newValue, props.Analytics)
			else
				props.AddKeyframe_deprecated(instanceName, trackName, playhead, newValue, props.Analytics)
			end
		end
	end)
end

function TrackActions:render()
	local props = self.props
	local showMenu = props.ShowMenu
	local trackName = props.TrackName
	local instanceName = props.InstanceName
	local animationData = props.AnimationData
	local playhead = props.Playhead

	local actions = self.Actions
	local pluginActions = self.props.PluginActions

	if not isEmpty(pluginActions) and actions ~= nil then
		for _, action in ipairs(actions) do
			action.Enabled = false
		end

		if trackName and instanceName then
			local instance = animationData.Instances[instanceName]
			local track = instance.Tracks[trackName]
			if not (track and track.Data and track.Data[playhead]) then
				pluginActions:get("AddKeyframe").Enabled = true
			end
		end

		pluginActions:get("DeleteTrack").Enabled = true
	end

	return showMenu and Roact.createElement(ContextMenu, {
		Actions = self:makeMenuActions(),
		OnMenuOpened = props.OnMenuOpened,
	}) or nil
end

function TrackActions:willUnmount()
	if self.Connections then
		for _, connection in ipairs(self.Connections) do
			connection:Disconnect()
		end
		self.Connections = {}
	end
	if self.Actions then
		for _, action in ipairs(self.Actions) do
			action.Enabled = false
		end
	end
end

ContextServices.mapToProps(TrackActions,{
	PluginActions = ContextServices.PluginActions,
	Analytics = ContextServices.Analytics,
})

local function mapStateToProps(state, props)
	local status = state.Status

	return {
		AnimationData = state.AnimationData,
		TrackName = status.RightClickContextInfo.TrackName,
		TrackType = status.RightClickContextInfo.TrackType,
		InstanceName = status.RightClickContextInfo.InstanceName,
		Playhead = status.Playhead,
	}
end

local function mapDispatchToProps(dispatch)
	return{
		DeleteTrack = function(trackName, analytics)
			dispatch(AddWaypoint())
			dispatch(DeleteTrack(trackName, analytics))
			dispatch(SetRightClickContextInfo({}))
		end,

		AddKeyframe = function(instance, trackName, trackType, frame, value, analytics)
			dispatch(AddWaypoint())
			dispatch(AddKeyframe(instance, trackName, trackType, frame, value, analytics))
			dispatch(SetRightClickContextInfo({}))
		end,

		-- Remove when GetFFlagFacialAnimationSupport() is retired
		AddKeyframe_deprecated = function(instance, trackName, frame, value, analytics)
			dispatch(AddWaypoint())
			dispatch(AddKeyframe(instance, trackName, frame, value, analytics))
			dispatch(SetRightClickContextInfo({}))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TrackActions)