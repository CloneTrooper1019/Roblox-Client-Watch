--[[
	Represents the main Editor frame split into two parts. The TrackEditor which handles the
	DopeSheet, Timeline, and ZoomBar. Then there is the other part that handles the playback
	controls and the track list.

	Properties:
		UDim2 Position = position of the frame
		UDim2 Size = size of the frame
		int ZIndex = The draw index of the frame.
]]
local UserInputService = game:GetService("UserInputService")

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local UILibrary = require(Plugin.UILibrary)
local Input = require(Plugin.SrcDeprecated.Util.Input)
local Constants = require(Plugin.SrcDeprecated.Util.Constants)
local TrackUtils = require(Plugin.SrcDeprecated.Util.TrackUtils)
local AnimationData = require(Plugin.SrcDeprecated.Util.AnimationData)

local KeyboardListener = UILibrary.Focus.KeyboardListener
local InactiveCover = require(Plugin.SrcDeprecated.Components.InactiveCover)

local TrackEditor = require(Plugin.SrcDeprecated.Components.TrackEditor)
local TrackList = require(Plugin.SrcDeprecated.Components.TrackList.TrackList)
local TrackActions = require(Plugin.SrcDeprecated.Components.TrackActions)
local TrackListBorder = require(Plugin.SrcDeprecated.Components.TrackList.TrackListBorder)
local AnimationEventsTrack = require(Plugin.SrcDeprecated.Components.TrackList.AnimationEventsTrack)
local TrackScrollbar = require(Plugin.SrcDeprecated.Components.TrackList.TrackScrollbar)
local StartScreen = require(Plugin.SrcDeprecated.Components.StartScreen)
local BigAnimationScreen = require(Plugin.SrcDeprecated.Components.BigAnimationScreen)
local FloorGrid = require(Plugin.SrcDeprecated.Components.FloorGrid)
local ChangeFPSPrompt = require(Plugin.SrcDeprecated.Components.ChangeFPSPrompt)

local SettingsButton = require(Plugin.SrcDeprecated.Components.SettingsButton)

local AddTrack = require(Plugin.SrcDeprecated.Thunks.AddTrack)
local SetTracksExpanded = require(Plugin.SrcDeprecated.Actions.SetTracksExpanded)
local SetSelectedTracks = require(Plugin.SrcDeprecated.Actions.SetSelectedTracks)
local MoveSelectedTrack = require(Plugin.SrcDeprecated.Thunks.MoveSelectedTrack)
local SetRightClickContextInfo = require(Plugin.SrcDeprecated.Actions.SetRightClickContextInfo)
local SetMotorData = require(Plugin.SrcDeprecated.Actions.SetMotorData)
local ValueChanged = require(Plugin.SrcDeprecated.Thunks.ValueChanged)
local AddWaypoint = require(Plugin.SrcDeprecated.Thunks.History.AddWaypoint)
local AttachEditor = require(Plugin.SrcDeprecated.Thunks.AttachEditor)
local ReleaseEditor = require(Plugin.SrcDeprecated.Thunks.ReleaseEditor)
local SetEventEditingFrame = require(Plugin.SrcDeprecated.Actions.SetEventEditingFrame)
local LoadAnimationData = require(Plugin.SrcDeprecated.Thunks.LoadAnimationData)
local SetIsPlaying = require(Plugin.SrcDeprecated.Actions.SetIsPlaying)
local SetIsDirty = require(Plugin.SrcDeprecated.Actions.SetIsDirty)
local SetFrameRate = require(Plugin.SrcDeprecated.Thunks.SetFrameRate)

local Playback = require(Plugin.SrcDeprecated.Components.Playback)
local InstanceSelector = require(Plugin.SrcDeprecated.Components.InstanceSelector)
local JointSelector = require(Plugin.SrcDeprecated.Components.JointManipulator.JointSelector)
local AnimationControlPanel = require(Plugin.SrcDeprecated.Components.AnimationControlPanel.AnimationControlPanel)
local TrackColors = require(Plugin.SrcDeprecated.Components.TrackList.TrackColors)

local GetFFlagDebugExtendAnimationLimit = require(Plugin.LuaFlags.GetFFlagDebugExtendAnimationLimit)

local EditorController = Roact.PureComponent:extend("EditorController")

function EditorController:init()
	self.state = {
		TopTrackIndex = 1,
		AbsoluteSize = Vector2.new(),
		TrackListWidth = Constants.TRACK_LIST_START_WIDTH,
		showContextMenu = false,
		showChangeFPSPrompt = false,
	}

	self.showChangeFPSPrompt = function()
		self:setState({
			showChangeFPSPrompt = true,
		})
	end

	self.hideChangeFPSPrompt = function()
		self:setState({
			showChangeFPSPrompt = false,
		})
	end

	self.setTopTrackIndex = function(index)
		local tracks = self.props.Tracks
		if #tracks > 0 then
			self:setState({
				TopTrackIndex = math.clamp(index, 1, #tracks)
			})
		end
	end

	self.onScroll = function(delta)
		local topTrackIndex = self.state.TopTrackIndex
		self.setTopTrackIndex(topTrackIndex - delta)
	end

	self.onSizeUpdate = function(rbx)
		local trackListWidth = math.min(self.state.TrackListWidth,
			rbx.AbsoluteSize.X - Constants.TIMELINE_MIN_WIDTH)
		self:setState({
			AbsoluteSize = rbx.AbsoluteSize,
			TrackListWidth = trackListWidth,
		})
	end

	self.showMenu = function(track)
		self.props.SetIsPlaying(false)
		self.props.SetRightClickContextInfo({
			TrackName = track.Name,
			InstanceName = track.Instance,
		})
		self:setState({
			showContextMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showContextMenu = false,
		})
	end

	self.updateTrackListWidth = function(input)
		local xPos = input.Position.X
		local trackListWidth = math.clamp(xPos, Constants.TRACK_LIST_MIN_WIDTH,
			self.state.AbsoluteSize.X - Constants.TIMELINE_MIN_WIDTH)
		self:setState({
			TrackListWidth = trackListWidth,
		})
	end

	self.controlSelectTrack = function(trackName)
		local props = self.props
		local selectedTracks = props.SelectedTracks
		local setSelectedTracks = props.SetSelectedTracks

		if selectedTracks and Cryo.List.find(selectedTracks, trackName) then
			setSelectedTracks(Cryo.List.removeValue(selectedTracks, trackName))
		else
			self.lastSelected = trackName
			setSelectedTracks(Cryo.List.join(selectedTracks or {}, {trackName}))
		end
	end

	self.shiftSelectTrack = function(trackName)
		local props = self.props
		local tracks = props.Tracks
		local setSelectedTracks = props.SetSelectedTracks

		local currentSelectedIndex, lastSelectedIndex
		for index, track in ipairs(tracks) do
			if track.Name == self.lastSelected then
				lastSelectedIndex = index
			elseif track.Name == trackName then
				currentSelectedIndex = index
			end
		end
		if currentSelectedIndex ~= nil and lastSelectedIndex ~= nil then
			local startIndex = math.min(currentSelectedIndex, lastSelectedIndex)
			local endIndex = math.max(currentSelectedIndex, lastSelectedIndex)
			local newSelectedTracks = {}
			for i = startIndex, endIndex do
				table.insert(newSelectedTracks, tracks[i].Name)
			end
			setSelectedTracks(newSelectedTracks)
		else
			self.lastSelected = trackName
			setSelectedTracks({trackName})
		end
	end

	self.onTrackSelected = function(trackName)
		local props = self.props
		local setSelectedTracks = props.SetSelectedTracks

		if self.controlDown then
			self.controlSelectTrack(trackName)
		elseif self.shiftDown then
			self.shiftSelectTrack(trackName)
		else
			self.lastSelected = trackName
			setSelectedTracks({trackName})
		end

		props.Analytics:onTrackSelected(trackName, "TrackList")
	end

	self.onPartSelected = function(trackName)
		local props = self.props
		local setSelectedTracks = props.SetSelectedTracks
		local inputObjects = UserInputService:GetKeysPressed()

		for _, input in ipairs(inputObjects) do
			if Input.isControl(input.KeyCode) then
				self.controlSelectTrack(trackName)
				return
			end
		end
		self.lastSelected = trackName
		setSelectedTracks({trackName})
	end
end

function EditorController:render()
	local props = self.props
	local state = self.state

	local startFrame = 0
	local endFrame = 0
	local lastFrame = 0
	local active = props.Active
	local playhead = props.Playhead
	local showAsSeconds = props.ShowAsSeconds
	local editingLength = props.EditingLength
	local topTrackIndex = state.TopTrackIndex
	local trackListWidth = state.TrackListWidth
	local tracks = props.Tracks
	local unusedTracks = props.UnusedTracks
	local scroll = props.Scroll
	local zoom = props.Zoom
	local animationData = props.AnimationData
	local showEvents = props.ShowEvents
	local selectedTracks = props.SelectedTracks
	local rootInstance = props.RootInstance

	local absoluteSize = state.AbsoluteSize
	local showChangeFPSPrompt = state.showChangeFPSPrompt

	if animationData then
		local range = TrackUtils.getZoomRange(props.AnimationData, scroll, zoom, editingLength)
		startFrame = range.Start
		endFrame = range.End
		lastFrame = animationData.Metadata.EndFrame
	end

	local showEditor = animationData ~= nil
	local bigAnimation = false
	if animationData and GetFFlagDebugExtendAnimationLimit() then
		local length = animationData.Metadata.EndFrame / animationData.Metadata.FrameRate
		if length >= Constants.MAX_DISPLAYED_TIME then
			bigAnimation = true
		end
	end
	showEvents = showEvents and showEditor

	local rootName
	if props.RootInstance and props.RootInstance.Name then
		rootName = props.RootInstance.Name
	else
		rootName = ""
	end

	local zIndex = props.ZIndex or 1
	local position = props.Position
	local size = props.Size

	local colorsPosition = (showEvents and Constants.TRACK_HEIGHT or 0)	+ Constants.TIMELINE_HEIGHT
		+ Constants.SUMMARY_TRACK_HEIGHT

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		ZIndex = zIndex,
		Position = position,
		Size = size,
		[Roact.Change.AbsoluteSize] = self.onSizeUpdate,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),

		TrackListAndControlContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, trackListWidth, 1, 0),
			LayoutOrder = 0,
		}, {
			AnimationControlPanel = Roact.createElement(AnimationControlPanel, {
				StartFrame = startFrame,
				EndFrame = endFrame,
				Playhead = playhead,
				EditingLength = editingLength,
				AnimationData = props.AnimationData,
				ShowAsSeconds = showAsSeconds,
			}),

			EventsAndTracks = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, trackListWidth, 1, -Constants.TIMELINE_HEIGHT),
				Position = UDim2.new(0, 0, 0, Constants.TIMELINE_HEIGHT),
				BackgroundTransparency = 1,
				ImageTransparency = 1,

				[Roact.Event.Activated] = function()
					props.SetSelectedTracks()
				end,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				EventsTitle = showEvents and Roact.createElement(AnimationEventsTrack, {
					LayoutOrder = 0,
					Indent = 1,
					OnButtonClick = function()
						props.SetEventEditingFrame(playhead)
					end,
				}),

				TrackList = Roact.createElement(TrackList, {
					Size = showEvents and UDim2.new(1, 0, 1, -Constants.TRACK_HEIGHT)
						or UDim2.new(1, 0, 1, 0),
					LayoutOrder = 1,
					TopTrackIndex = topTrackIndex,
					Tracks = tracks,
					SelectedTracks = selectedTracks,
					UnusedTracks = unusedTracks,
					AnimationData = animationData,
					Playhead = playhead,
					RootName = rootName,

					OnScroll = self.onScroll,
					OpenContextMenu = self.showMenu,
					ToggleTrackExpanded = props.SetTracksExpanded,
					OnTrackAdded = props.AddTrack,
					OnValueChanged = props.ValueChanged,
					OnChangeBegan = props.AddWaypoint,
					OnTrackSelected = self.onTrackSelected,
				}),

				KeyboardListener = Roact.createElement(KeyboardListener, {
					OnKeyPressed = function(input)
						if Input.isUp(input.KeyCode) then
							props.MoveSelectedTrack(-1)
						elseif Input.isDown(input.KeyCode) then
							props.MoveSelectedTrack(1)
						elseif Input.isLeft(input.KeyCode) then
							props.CloseSelectedTracks(selectedTracks)
						elseif Input.isRight(input.KeyCode) then
							props.ExpandSelectedTracks(selectedTracks)
						elseif Input.isControl(input.KeyCode) then
							self.controlDown = true
						elseif Input.isShift(input.KeyCode) then
							self.shiftDown = true
						end
					end,
					OnKeyReleased = function(input)
						if Input.isControl(input.KeyCode) then
							self.controlDown = false
						elseif Input.isShift(input.KeyCode) then
							self.shiftDown = false
						end
					end,
				}),
			}),
		}),

		TrackListBorder = Roact.createElement(TrackListBorder, {
			OnDragMoved = self.updateTrackListWidth,
		}),

		TrackEditor = showEditor and not bigAnimation and Roact.createElement(TrackEditor, {
			ZIndex = zIndex,
			TopTrackIndex = topTrackIndex,
			Tracks = tracks,
			LayoutOrder = 2,
			Size = UDim2.new(1, -trackListWidth - Constants.SCROLL_BAR_SIZE
				- Constants.SCROLL_BAR_PADDING, 1, 0),
			StartFrame = startFrame,
			EndFrame = endFrame,
			LastFrame = lastFrame,
			Playhead = playhead,
			FrameRate = animationData and animationData.Metadata and animationData.Metadata.FrameRate,
			ShowAsSeconds = showAsSeconds,
			ShowEvents = showEvents,
			Scroll = scroll,
			Zoom = zoom,
			OnScroll = self.onScroll,
		}),

		SettingsAndVerticalScrollBar = showEditor and not bigAnimation and Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, Constants.SCROLL_BAR_SIZE, 1, 0),
			LayoutOrder = 3,
		}, {
			SettingsButton = Roact.createElement(SettingsButton, {
				OnChangeFPS = self.showChangeFPSPrompt,
			}),

			TrackScrollbar = Roact.createElement(TrackScrollbar, {
				Size = UDim2.new(1, 0, 1, -Constants.SCROLL_BAR_SIZE - Constants.TIMELINE_HEIGHT - 1),
				Position = UDim2.new(0, 0, 0, Constants.TIMELINE_HEIGHT),
				TopTrackIndex = topTrackIndex,
				NumTracks = tracks and #tracks or 0,
				SetTopTrackIndex = self.setTopTrackIndex,
				OnScroll = self.onScroll,
			}),
		}),

		BigAnimationScreen = bigAnimation and Roact.createElement(BigAnimationScreen, {
			Size = UDim2.new(1, -trackListWidth, 1, 0),
			LayoutOrder = 2,
		}),

		StartScreen = not showEditor and Roact.createElement(StartScreen, {
			RootInstance = rootInstance,
			Size = UDim2.new(1, -trackListWidth, 1, 0),
			LayoutOrder = 2,
			OnCreateAnimation = props.CreateAnimation,
		}),

		Playback = active and showEditor and Roact.createElement(Playback),
		InstanceSelector = active and Roact.createElement(InstanceSelector),

		JointSelector = active and showEditor and Roact.createElement(JointSelector, {
			RootInstance = props.RootInstance,
			IKEnabled = props.IKEnabled,
			IKMode = props.IKMode,
			MotorData = props.MotorData,
			PinnedParts = props.PinnedParts,
			SetMotorData = props.SetMotorData,
			SelectedTracks = selectedTracks,
			OnSelectPart = self.onPartSelected,
			OnDragStart = props.AddWaypoint,
			OnManipulateJoint = function(instanceName, trackName, value)
				props.ValueChanged(instanceName, trackName, playhead, value)
			end,
			OnManipulateJoints = function(instanceName, values)
				for trackName, value in pairs(values) do
					props.ValueChanged(instanceName, trackName, playhead, value)
				end
			end,
		}),

		FloorGrid = active and showEditor and Roact.createElement(FloorGrid, {
			RootInstance = props.RootInstance,
		}),

		TrackActions = active and showEditor and Roact.createElement(TrackActions, {
			ShowMenu = state.showContextMenu,
			OnMenuOpened = self.hideMenu,
		}),

		IgnoreLayout = showEditor and Roact.createElement("Folder", {}, {
			TrackColors = Roact.createElement(TrackColors, {
				Tracks = tracks,
				TopTrackIndex = topTrackIndex,
				Position = UDim2.new(0, 0, 0, colorsPosition),
				MaxHeight = absoluteSize.Y - Constants.TRACK_HEIGHT - colorsPosition,
			}),
		}),

		InactiveCover = not active and Roact.createElement(InactiveCover, {
			OnFocused = props.AttachEditor,
		}),

		ChangeFPSPrompt = showChangeFPSPrompt and Roact.createElement(ChangeFPSPrompt, {
			FrameRate = animationData and animationData.Metadata and animationData.Metadata.FrameRate,
			SetFrameRate = props.SetFrameRate,
			OnClose = self.hideChangeFPSPrompt,
		}),
	})
end

function EditorController:didMount()
	local props = self.props
	local snapToKeys = props.SnapToKeys
	local timelineUnit = props.ShowAsSeconds and "Seconds" or "Frames"
	props.AttachEditor()
	props.Analytics:onEditorOpened(timelineUnit, snapToKeys)
end

function EditorController:willUnmount()
	local props = self.props
	props.ReleaseEditor()
	props.Analytics:onEditorClosed()
end

local function mapStateToProps(state, props)
	local status = state.Status

	return {
		Active = state.Status.Active,
		EditingLength = state.Status.EditingLength,
		Playhead = state.Status.Playhead,
		ShowAsSeconds = state.Status.ShowAsSeconds,
		SnapToKeys = state.Status.SnapToKeys,
		AnimationData = state.AnimationData,
		Scroll = status.Scroll,
		Zoom = status.Zoom,
		Tracks = status.Tracks,
		UnusedTracks = status.UnusedTracks,
		RootInstance = status.RootInstance,
		ShowEvents = status.ShowEvents,
		IKEnabled = status.IKEnabled,
		IKMode = status.IKMode,
		MotorData = status.MotorData,
		PinnedParts = status.PinnedParts,
		SelectedTracks = status.SelectedTracks,

		Analytics = state.Analytics,
	}
end

local function mapDispatchToProps(dispatch)
	local dispatchToProps = {
		SetTracksExpanded = function(tracks, expanded)
			dispatch(SetTracksExpanded(tracks, expanded))
		end,

		SetSelectedTracks = function(tracks)
			dispatch(SetSelectedTracks(tracks))
		end,

		MoveSelectedTrack = function(movement)
			dispatch(MoveSelectedTrack(movement))
		end,

		ExpandSelectedTracks = function(tracks)
			dispatch(SetTracksExpanded(tracks, true))
		end,

		CloseSelectedTracks = function(tracks)
			dispatch(SetTracksExpanded(tracks, false))
		end,

		AddTrack = function(instance, track)
			dispatch(AddWaypoint())
			dispatch(AddTrack(instance, track))
		end,

		SetRightClickContextInfo = function(info)
			dispatch(SetRightClickContextInfo(info))
		end,

		ValueChanged = function(instanceName, trackName, frame, value)
			dispatch(ValueChanged(instanceName, trackName, frame, value))
		end,

		AddWaypoint = function()
			dispatch(AddWaypoint())
		end,

		AttachEditor = function()
			dispatch(AttachEditor())
		end,

		ReleaseEditor = function()
			dispatch(ReleaseEditor())
		end,

		SetEventEditingFrame = function(frame)
			dispatch(SetEventEditingFrame(frame))
		end,

		SetMotorData = function(motorData)
			dispatch(SetMotorData(motorData))
		end,

		CreateAnimation = function(name)
			local newData = AnimationData.newRigAnimation(name)
			dispatch(LoadAnimationData(newData))
			dispatch(SetIsDirty(false))
		end,

		SetFrameRate = function(frameRate)
			dispatch(SetFrameRate(frameRate))
		end,

		SetIsPlaying = function(isPlaying)
			dispatch(SetIsPlaying(isPlaying))
		end,
	}

	return dispatchToProps
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(EditorController)
