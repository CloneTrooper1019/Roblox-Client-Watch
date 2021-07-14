--[[
	Handles timeline actions and the context menu.
	When this component renders, it determines which actions should be enabled.
	This allows keyboard shortcuts to work only when they provide meaningful action.
	When the ShowMenu prop is true, this component also spawns a context menu
	to show the actions controlled by this component. Disabled actions will appear
	greyed out in this menu.

	Props:
		bool ShowMenu = Whether to show the context menu.
		bool MultipleSelected = Whether multiple keyframes are selected.

		function OnMenuOpened() = A callback for when the context menu has successfully opened.
		function OnItemSelected(key, item) = A callback for when the user selects an
			item in one of the submenus to edit a key's Easing info.
		function OnRenameKeyframe(frame) = A callback for when the user wants to start renaming
			a keyframe in the timeline.
]]

local EASING_STYLE_ORDER = {
	Enum.PoseEasingStyle.Linear,
	Enum.PoseEasingStyle.Constant,
	Enum.PoseEasingStyle.Cubic,
	Enum.PoseEasingStyle.Elastic,
	Enum.PoseEasingStyle.Bounce,
}

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local Constants = require(Plugin.Src.Util.Constants)
local SignalsContext = require(Plugin.Src.Context.Signals)

local ContextMenu = require(Plugin.Src.Components.ContextMenu)

local KeyframeUtils = require(Plugin.Src.Util.KeyframeUtils)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)

local AddWaypoint = require(Plugin.Src.Thunks.History.AddWaypoint)
local AddKeyframe = require(Plugin.Src.Thunks.AddKeyframe)
local PasteKeyframes = require(Plugin.Src.Thunks.PasteKeyframes)
local CopySelectedKeyframes = require(Plugin.Src.Thunks.Selection.CopySelectedKeyframes)
local DeleteSelectedKeyframes = require(Plugin.Src.Thunks.Selection.DeleteSelectedKeyframes)
local ResetSelectedKeyframes = require(Plugin.Src.Thunks.Selection.ResetSelectedKeyframes)
local SetRightClickContextInfo = require(Plugin.Src.Actions.SetRightClickContextInfo)
local ToggleBoneVisibility = require(Plugin.Src.Thunks.ToggleBoneVisibility)

local SelectAllKeyframes = require(Plugin.Src.Thunks.Selection.SelectAllKeyframes)
local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local SetSelectedEvents = require(Plugin.Src.Actions.SetSelectedEvents)
local SetShowEvents = require(Plugin.Src.Actions.SetShowEvents)
local SetEventEditingFrame = require(Plugin.Src.Actions.SetEventEditingFrame)
local SetTool = require	(Plugin.Src.Actions.SetTool)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Undo = require(Plugin.Src.Thunks.History.Undo)
local Redo = require(Plugin.Src.Thunks.History.Redo)

local TogglePlay = require(Plugin.Src.Thunks.Playback.TogglePlay)

local FFlagAnimEditorFixBackspaceOnMac = require(Plugin.LuaFlags.GetFFlagAnimEditorFixBackspaceOnMac)
local FFlagAddKeyframeAtScrubber = game:DefineFastFlag("AddKeyframeAtScrubber", false)
local GetFFlagRefactorMenus = require(Plugin.LuaFlags.GetFFlagRefactorMenus)
local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local TimelineActions = Roact.PureComponent:extend("TimelineActions")

-- Returns the easing value shared among all selected keyframes,
-- or nil if any keyframes do not share the same easing info.
function TimelineActions:getSharedEasingValue(key)
	local props = self.props
	local selectedKeyframes = props.SelectedKeyframes
	local animationData = props.AnimationData

	local sharedEasingValue = nil
	for instanceName, instance in pairs(selectedKeyframes) do
		local dataInstance = animationData.Instances[instanceName]
		for trackName, _ in pairs(instance) do
			local keyframes = Cryo.Dictionary.keys(instance[trackName])
			local track = dataInstance.Tracks[trackName]
			for _, keyframe in ipairs(keyframes) do
				if track.Data[keyframe] then
					if sharedEasingValue == nil then
						sharedEasingValue = track.Data[keyframe][key]
					elseif sharedEasingValue ~= track.Data[keyframe][key] then
						sharedEasingValue = nil
						break
					end
				end
			end
		end
	end
	return sharedEasingValue and sharedEasingValue.Value
end

-- Creates a submenu for selecting an enum item.
function TimelineActions:makeSelectionSubMenu(enumKey, dataKey, displayText)
	local props = self.props

	return {
		Name = displayText,
		Items = enumKey == "PoseEasingStyle" and EASING_STYLE_ORDER or Enum[enumKey]:GetEnumItems(),
		CurrentItem = not GetFFlagRefactorMenus() and self:getSharedEasingValue(dataKey) or nil,
		CurrentValue = GetFFlagRefactorMenus() and self:getSharedEasingValue(dataKey) or nil,
		ItemSelected = function(item)
			props.OnItemSelected(dataKey, item)
		end,
	}
end

function TimelineActions:makeMenuActions(localization)
	local props = self.props
	local selectedKeyframes = props.SelectedKeyframes
	local summaryKeyframe = props.SummaryKeyframe
	local pluginActions = self.props.PluginActions

	local actions = {
		pluginActions:get("AddKeyframeHere"),
		pluginActions:get("DeleteSelected"),
		Constants.MENU_SEPARATOR,
		pluginActions:get("CutSelected"),
		pluginActions:get("CopySelected"),
		pluginActions:get("PasteKeyframes"),
		Constants.MENU_SEPARATOR,
	}

	if selectedKeyframes and not isEmpty(selectedKeyframes) then
		table.insert(actions, pluginActions:get("ResetSelected"))
		table.insert(actions, Constants.MENU_SEPARATOR)
		table.insert(actions, pluginActions:get("ChangeDuration"))
		-- EasingStyle and EasingDirection customization
		table.insert(actions, Constants.MENU_SEPARATOR)
		table.insert(actions, self:makeSelectionSubMenu("PoseEasingStyle", "EasingStyle",
			localization:getText("ContextMenu", "EasingStyle")))
		table.insert(actions, self:makeSelectionSubMenu("PoseEasingDirection", "EasingDirection",
			localization:getText("ContextMenu", "EasingDirection")))
	else
		table.insert(actions, pluginActions:get("AddResetKeyframe"))
	end

	table.insert(actions, Constants.MENU_SEPARATOR)
	table.insert(actions, pluginActions:get("AddEvent"))

	if summaryKeyframe ~= nil then
		table.insert(actions, pluginActions:get("RenameKeyframe"))
	end

	return actions
end

function TimelineActions:addAction(action, func)
	if action then
		action.Enabled = false
		table.insert(self.Actions, action)
		table.insert(self.Connections, action.Triggered:Connect(func))
	end
end

function TimelineActions:didMount()
	local actions = self.props.PluginActions
	self.Connections = {}
	self.Actions = {}

	self:addAction(actions:get("AddKeyframeHere"), function()
		local props = self.props
		local frame = props.Frame
		local trackName = props.TrackName
		local instanceName = props.InstanceName
		local tracks = props.Tracks

		local function addKeyframe(instanceName, trackName, track)
			-- The track type is nil when the user is adding a Pose to an empty track.
			-- In that case, use the right click info.
			local trackType = track and track.Type or props.TrackType
			local newValue

			if track and track.Keyframes then
				newValue = KeyframeUtils:getValue(track, frame)
			else
				if GetFFlagFacialAnimationSupport() then
					-- If the type could not be determined by an existing track or by
					-- the right click context, then find it in the open tracks
					trackType = trackType or TrackUtils.getTrackTypeFromName(trackName, tracks)
					newValue = TrackUtils.getDefaultValueByType(trackType)
				else
					newValue = TrackUtils.getDefaultValue(track)
				end
			end
			if GetFFlagFacialAnimationSupport() then
				props.AddKeyframe(instanceName, trackName, trackType, frame, newValue, props.Analytics)
			else
				props.AddKeyframe_deprecated(instanceName, trackName, frame, newValue, props.Analytics)
			end
		end

		if instanceName and trackName then
			local instance = props.AnimationData.Instances[instanceName]
			local track = instance.Tracks[trackName]
			addKeyframe(instanceName, trackName, track)
		else
			-- If the user clicked the summary track, add a keyframe for
			-- every currently opened track.
			for instanceName, instance in pairs(props.AnimationData.Instances) do
				for _, openTrack in pairs(tracks) do
					local trackName = openTrack.Name
					local track = instance.Tracks[trackName]
					addKeyframe(instanceName, trackName, track)
				end
			end
		end
	end)

	if FFlagAddKeyframeAtScrubber then
		self:addAction(actions:get("AddKeyframeAtScrubber"), function()
			local props = self.props
			local tracks = props.Tracks
			local playhead = props.Playhead
			local selectedTracks = props.SelectedTracks

			if selectedTracks then
				for instanceName, instance in pairs(props.AnimationData.Instances) do
					for _, selectedTrack in pairs(selectedTracks) do
						local track = instance.Tracks[selectedTrack]
						local newValue
						local trackType = track and track.Type

						if track and track.Keyframes then
							newValue = KeyframeUtils:getValue(track, playhead)
						else
							if GetFFlagFacialAnimationSupport() then
								trackType = trackType or TrackUtils.getTrackTypeFromName(selectedTrack, tracks)
								newValue = TrackUtils.getDefaultValueByType(trackType)
							else
								newValue = TrackUtils.getDefaultValue(track)
							end
						end
						if GetFFlagFacialAnimationSupport() then
							props.AddKeyframe(instanceName, selectedTrack, trackType, playhead, newValue, props.Analytics)
						else
							props.AddKeyframe_deprecated(instanceName, selectedTrack, playhead, newValue, props.Analytics)
						end
					end
				end
			end
		end)
	end

	self:addAction(actions:get("AddResetKeyframe"), function()
		local props = self.props
		local frame = props.Frame
		local trackName = props.TrackName
		local instanceName = props.InstanceName
		local tracks = props.Tracks

		if instanceName and trackName then
			local instance = props.AnimationData.Instances[instanceName]
			local track = instance.Tracks[trackName]
			local newValue
			local trackType = track and track.Type or props.TrackType

			if GetFFlagFacialAnimationSupport() then
				newValue = TrackUtils.getDefaultValueByType(trackType)
				props.AddKeyframe(instanceName, trackName, trackType, frame, newValue, props.Analytics)
			else
				newValue = TrackUtils.getDefaultValue(track)
				props.AddKeyframe_deprecated(instanceName, trackName, frame, newValue, props.Analytics)
			end
		else
			-- If the user clicked the summary track, add a reset keyframe for
			-- every currently opened track.
			for instanceName, instance in pairs(props.AnimationData.Instances) do
				for _, openTrack in pairs(tracks) do
					local trackName = openTrack.Name
					local track = instance.Tracks[trackName]
					local newValue
					local trackType

					if GetFFlagFacialAnimationSupport() then
						trackType = track and track.Type or TrackUtils.getTrackTypeFromName(trackName, tracks)
						newValue = TrackUtils.getDefaultValueByType(trackType)
						props.AddKeyframe(instanceName, trackName, trackType, frame, newValue, props.Analytics)
					else
						newValue = TrackUtils.getDefaultValue(track)
						props.AddKeyframe_deprecated(instanceName, trackName, frame, newValue, props.Analytics)
					end
				end
			end
		end
	end)

	self:addAction(actions:get("RenameKeyframe"), function()
		local props = self.props
		props.OnRenameKeyframe(props.Frame)
	end)

	self:addAction(actions:get("PasteKeyframes"), function()
		local props = self.props
		local frame = props.Frame or props.Playhead
		props.PasteKeyframes(frame, props.Analytics)
	end)

	self:addAction(actions:get("CutSelected"), function()
		local props = self.props
		props.CopySelectedKeyframes()
		props.DeleteSelectedKeyframes(props.Analytics)
	end)

	self:addAction(actions:get("AddEvent"), function()
		local props = self.props
		local frame = props.Frame
		props.OnEditEvents(frame)
	end)

	self:addAction(actions:get("ToggleTool"), function()
		local props = self.props
		local tool = props.Tool
		if tool == Enum.RibbonTool.Move then
			props.SetTool(Enum.RibbonTool.Rotate)
		else
			props.SetTool(Enum.RibbonTool.Move)
		end
	end)

	local function togglePlayWrapper()
		return self.props.TogglePlay(self.props.Analytics)
	end

	local function deleteSelectedKeyframesWrapper()
		return self.props.DeleteSelectedKeyframes(self.props.Analytics)
	end

	local function undoWrapper()
		return self.props.Undo(self.props.Signals)
	end


	self:addAction(actions:get("CopySelected"), self.props.CopySelectedKeyframes)
	self:addAction(actions:get("DeleteSelected"), deleteSelectedKeyframesWrapper)
	if FFlagAnimEditorFixBackspaceOnMac() then
		self:addAction(actions:get("DeleteSelectedBackspace"), deleteSelectedKeyframesWrapper)
	end
	self:addAction(actions:get("ResetSelected"), self.props.ResetSelectedKeyframes)
	self:addAction(actions:get("SelectAll"), self.props.SelectAllKeyframes)
	self:addAction(actions:get("DeselectAll"), self.props.DeselectAllKeyframes)
	self:addAction(actions:get("ChangeDuration"), self.props.OnChangeDuration)

	self:addAction(actions:get("Undo"), undoWrapper)
	self:addAction(actions:get("Redo"), self.props.Redo)

	self:addAction(actions:get("TogglePlay"), togglePlayWrapper)
	self:addAction(actions:get("ToggleBoneVis"), self.props.ToggleBoneVisibility)
end

function TimelineActions:render()
	local props = self.props
	local showMenu = props.ShowMenu
	local clipboard = props.Clipboard
	local clipboardType = props.ClipboardType
	local selectedKeyframes = props.SelectedKeyframes
	local summaryKeyframe = props.SummaryKeyframe
	local multipleSelected = props.MultipleSelected
	local tool = props.Tool
	local tracks = props.Tracks

	local actions = self.Actions
	local pluginActions = self.props.PluginActions
	if not isEmpty(pluginActions) and actions ~= nil then
		for _, action in ipairs(actions) do
			action.Enabled = false
		end

		if clipboard and not isEmpty(clipboard)
			and clipboardType == Constants.CLIPBOARD_TYPE.Keyframes then
			pluginActions:get("PasteKeyframes").Enabled = true
		end

		if selectedKeyframes and not isEmpty(selectedKeyframes) then
			pluginActions:get("DeselectAll").Enabled = true
			pluginActions:get("CutSelected").Enabled = true
			pluginActions:get("CopySelected").Enabled = true
			pluginActions:get("ResetSelected").Enabled = true
			pluginActions:get("DeleteSelected").Enabled = true
			if FFlagAnimEditorFixBackspaceOnMac() then
				pluginActions:get("DeleteSelectedBackspace").Enabled = true
			end
		else
			pluginActions:get("SelectAll").Enabled = true
		end

		if not props.OnKeyframe and not isEmpty(tracks) then
			pluginActions:get("AddKeyframeHere").Enabled = true
			pluginActions:get("AddResetKeyframe").Enabled = true
		end

		if FFlagAddKeyframeAtScrubber then
			pluginActions:get("AddKeyframeAtScrubber").Enabled = true
		end

		if multipleSelected then
			pluginActions:get("ChangeDuration").Enabled = true
		end

		if summaryKeyframe ~= nil then
			pluginActions:get("RenameKeyframe").Enabled = true
		end

		if tool == Enum.RibbonTool.Rotate or tool == Enum.RibbonTool.Move then
			pluginActions:get("ToggleTool").Enabled = true
		end

		pluginActions:get("Undo").Enabled = true
		pluginActions:get("Redo").Enabled = true
		pluginActions:get("TogglePlay").Enabled = true
		pluginActions:get("AddEvent").Enabled = true
		pluginActions:get("ToggleBoneVis").Enabled = true
	end

	local localization = self.props.Localization
		return showMenu and Roact.createElement(ContextMenu, {
			Actions = self:makeMenuActions(localization),
			OnMenuOpened = props.OnMenuOpened,
		}) or nil
end

function TimelineActions:willUnmount()
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

ContextServices.mapToProps(TimelineActions, {
	Localization = ContextServices.Localization,
	PluginActions = ContextServices.PluginActions,
	Analytics = ContextServices.Analytics,
	Signals = SignalsContext,
})

local function mapStateToProps(state, props)
	local status = state.Status

	local stateToProps = {
		Clipboard = status.Clipboard,
		ClipboardType = status.ClipboardType,
		SelectedKeyframes = status.SelectedKeyframes,
		Playhead = status.Playhead,
		AnimationData = state.AnimationData,
		Tracks = status.Tracks,
		TrackName = status.RightClickContextInfo.TrackName,
		TrackType = status.RightClickContextInfo.TrackType,
		InstanceName = status.RightClickContextInfo.InstanceName,
		Frame = status.RightClickContextInfo.Frame,
		SummaryKeyframe = status.RightClickContextInfo.SummaryKeyframe,
		OnKeyframe = status.RightClickContextInfo.OnKeyframe,
		Tool = status.Tool,
	}

	if FFlagAddKeyframeAtScrubber then
		stateToProps["SelectedTracks"] = status.SelectedTracks
	end

	return stateToProps
end

local function mapDispatchToProps(dispatch)
	return{
		SelectAllKeyframes = function()
			dispatch(SelectAllKeyframes())
			dispatch(SetSelectedEvents({}))
		end,

		DeselectAllKeyframes = function()
			dispatch(SetSelectedKeyframes{})
			dispatch(SetSelectedEvents({}))
		end,

		DeleteSelectedKeyframes = function(analytics)
			dispatch(AddWaypoint())
			dispatch(DeleteSelectedKeyframes(analytics))
			dispatch(SetRightClickContextInfo({}))
		end,

		ResetSelectedKeyframes = function()
			dispatch(AddWaypoint())
			dispatch(ResetSelectedKeyframes())
			dispatch(SetRightClickContextInfo({}))
		end,

		CopySelectedKeyframes = function()
			dispatch(CopySelectedKeyframes())
			dispatch(SetRightClickContextInfo({}))
		end,

		PasteKeyframes = function(frame, analytics)
			dispatch(AddWaypoint())
			dispatch(PasteKeyframes(frame, analytics))
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

		OnEditEvents = function(frame)
			dispatch(SetShowEvents(true))
			dispatch(SetEventEditingFrame(frame))
		end,

		Undo = function(signals)
			dispatch(Undo(signals))
		end,

		Redo = function()
			dispatch(Redo())
		end,

		TogglePlay = function(analytics)
			dispatch(TogglePlay(analytics))
		end,

		SetTool = function(tool)
			dispatch(SetTool(tool))
		end,

		ToggleBoneVisibility = function()
			dispatch(ToggleBoneVisibility())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(TimelineActions)