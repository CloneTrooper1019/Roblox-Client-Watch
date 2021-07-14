--[[
	A controller than handles keyframe manipulation events in the Dope Sheet.
	Accepts input from the Dope Sheet itself and keyframes within it, and
	connects these events to thunks and drag logic.

	Props:
		int StartFrame = beginning frame of timeline range
		int EndFrame = end frame of timeline range
		int TrackPadding = amount of total padding
		int TopTrackIndex = index of the track that should be displayed at the top of the Dope Sheet
		bool ShowEvents = Whether to show the AnimationEvents track.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)
local AnimationData = require(Plugin.Src.Util.AnimationData)

local Framework = require(Plugin.Packages.Framework)
local DragTarget = Framework.UI.DragListener
local ContextServices = Framework.ContextServices
local KeyboardListener = Framework.UI.KeyboardListener

local Preview = require(Plugin.Src.Util.Preview)
local DragContext = require(Plugin.Src.Util.DragContext)

local Input = require(Plugin.Src.Util.Input)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local Constants = require(Plugin.Src.Util.Constants)
local StringUtils = require(Plugin.Src.Util.StringUtils)

local DopeSheet = require(Plugin.Src.Components.DopeSheet)
local EventsController = require(Plugin.Src.Components.EventsController)
local SelectionBox = require(Plugin.Src.Components.SelectionBox)
local TimelineActions = require(Plugin.Src.Components.TimelineActions)
local ScaleControls = require(Plugin.Src.Components.ScaleControls.ScaleControls)
local TextEntryPrompt = require(Plugin.Src.Components.TextEntryPrompt)
local ActionToast = require(Plugin.Src.Components.Toast.ActionToast)
local NoticeToast = require(Plugin.Src.Components.Toast.NoticeToast)

local AddWaypoint = require(Plugin.Src.Thunks.History.AddWaypoint)
local SelectKeyframe = require(Plugin.Src.Thunks.Selection.SelectKeyframe)
local DeselectKeyframe = require(Plugin.Src.Thunks.Selection.DeselectKeyframe)
local SelectKeyframesAtFrame = require(Plugin.Src.Thunks.Selection.SelectKeyframesAtFrame)
local DeselectKeyframesAtFrame = require(Plugin.Src.Thunks.Selection.DeselectKeyframesAtFrame)
local MoveSelectedKeyframes = require(Plugin.Src.Thunks.Selection.MoveSelectedKeyframes)
local ScaleSelectedKeyframes = require(Plugin.Src.Thunks.Selection.ScaleSelectedKeyframes)
local SetSelectedKeyframeData = require(Plugin.Src.Thunks.Selection.SetSelectedKeyframeData)
local DeleteSelectedKeyframes = require(Plugin.Src.Thunks.Selection.DeleteSelectedKeyframes)
local SetRightClickContextInfo = require(Plugin.Src.Actions.SetRightClickContextInfo)
local RenameKeyframe = require(Plugin.Src.Thunks.RenameKeyframe)
local QuantizeKeyframes = require(Plugin.Src.Thunks.QuantizeKeyframes)

local SetSelectedKeyframes = require(Plugin.Src.Actions.SetSelectedKeyframes)
local SetSelectedEvents = require(Plugin.Src.Actions.SetSelectedEvents)
local SetNotification = require(Plugin.Src.Actions.SetNotification)
local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)

local GetFFlagAddImportFailureToast = require(Plugin.LuaFlags.GetFFlagAddImportFailureToast)
local GetFFlagHideLoadToastIfAnimationClipped = require(Plugin.LuaFlags.GetFFlagHideLoadToastIfAnimationClipped)
local GetFFlagRealtimeChanges = require(Plugin.LuaFlags.GetFFlagRealtimeChanges)
local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local DopeSheetController = Roact.Component:extend("DopeSheetController")

function DopeSheetController:init()
	self.state = {
		AbsoluteSize = Vector2.new(),
		AbsolutePosition = Vector2.new(),
		dragging = false,
		draggingScale = false,
		draggingSelection = false,
		dragFrame = nil,
		showContextMenu = false,
		renamingKeyframe = nil,
		changingDuration = nil,
		hasDragWaypoint = false,	-- True if a waypoint has already been created for
									-- the current drag operation (move/scale)
	}

	if GetFFlagRealtimeChanges() then
		self.DragContext = nil
	else
		self.Preview = nil
	end

	self.isMultiSelecting = false
	self.mouseDownOnKeyframe = false
	self.mouseDownInTimeline = false
	self.tracks = {}

	self.selectDragStart, self.updateSelectDragStart = Roact.createBinding(nil)
	self.selectDragEnd, self.updateSelectDragEnd = Roact.createBinding(nil)
	self.lastMinFrame = nil
	self.lastMinTrack = nil
	self.lastMaxFrame = nil
	self.lastMaxTrack = nil

	self.getFrameFromPosition = function(position)
		return TrackUtils.getKeyframeFromPosition(
			position,
			self.props.StartFrame,
			self.props.EndFrame,
			self.state.AbsolutePosition.X + (self.props.TrackPadding / 2),
			self.state.AbsoluteSize.X - self.props.TrackPadding
		)
	end

	self.getTrackFromPosition = function(position)
		local topTrackIndex = self.props.TopTrackIndex
		local yPos = position.Y - self.state.AbsolutePosition.Y

		return TrackUtils.getTrackFromPosition(self.tracks, topTrackIndex, yPos)
	end

	self.addDragWaypoint = function()
		if not self.state.hasDragWaypoint then
			self.props.AddWaypoint()
			self:setState({
				hasDragWaypoint = true
			})
		end
	end

	self.onScaleHandleDragStarted = function(frame)
		local selectedKeyframes = self.props.SelectedKeyframes
		local animationData = self.props.AnimationData
		if GetFFlagRealtimeChanges() then
			self.DragContext = DragContext.new(animationData, selectedKeyframes, frame)
		else
			self.Preview = Preview.new(animationData, selectedKeyframes, frame)
		end
		self:setState({
			draggingScale = true,
			dragFrame = frame,
			hasDragWaypoint = false
		})
	end

	self.onKeyframeDragStarted = function(frame)
		local selectedKeyframes = self.props.SelectedKeyframes
		local animationData = self.props.AnimationData
		if GetFFlagRealtimeChanges() then
			self.DragContext = DragContext.new(animationData, selectedKeyframes, frame)
		else
			self.Preview = Preview.new(animationData, selectedKeyframes, frame)
		end
		self:setState({
			dragging = true,
			dragFrame = frame,
			hasDragWaypoint = false,
		})
	end

	self.onScaleHandleDragMoved = function(input)
		local frame = self.getFrameFromPosition(input.Position)
		if self.state.dragFrame ~= frame then
			if GetFFlagRealtimeChanges() then
				if self.DragContext then
					self.addDragWaypoint()
					self.DragContext:scaleKeyframes(frame, self.props.StartFrame)
					self.props.ScaleSelectedKeyframes(self.DragContext.pivotFrame, self.DragContext.scale, self.DragContext)
					self:setState({
						dragFrame = frame
					})
				end
			else
				if self.Preview then
					self.Preview:scaleKeyframes(self.props.AnimationData, self.props.SelectedKeyframes, frame, self.props.StartFrame)
					self:setState({
						dragFrame = frame
					})
				end
			end
		end
	end

	self.onKeyframeDragMoved = function(input)
		local frame = self.getFrameFromPosition(input.Position)
		if self.state.dragFrame ~= frame then
			if GetFFlagRealtimeChanges() then
				if self.DragContext then
					self.addDragWaypoint()
					self.DragContext:moveKeyframes(frame)
					self.props.MoveSelectedKeyframes(self.DragContext.pivotFrame, self.DragContext.newFrame, self.DragContext)
					self:setState({
						dragFrame = frame
					})
				end
			else
				if self.Preview then
					self.Preview:moveKeyframes(self.props.AnimationData, self.props.SelectedKeyframes, frame)
					self:setState({
						dragFrame = frame
					})
				end
			end
		end
	end

	self.onKeyframeDragEnded = function()
		if not GetFFlagRealtimeChanges() then
			local pivotFrame = self.Preview.pivotFrame
			local newFrame = self.Preview.newFrame
			self.props.MoveSelectedKeyframes(pivotFrame, newFrame)
		end
		self:setState({
			dragging = false,
			dragFrame = Roact.None,
			hasDragWaypoint = false,
		})
		if GetFFlagRealtimeChanges() then
			self.DragContext = nil
		else
			self.Preview = nil
		end
	end

	self.onScaleHandleDragEnded = function()
		if not GetFFlagRealtimeChanges() then
			local pivotFrame = self.Preview.pivotFrame
			local scale = self.Preview.scale
			self.props.ScaleSelectedKeyframes(pivotFrame, scale)
		end
		self:setState({
			draggingScale = false,
			dragFrame = Roact.None,
			hasDragWaypoint = false,
		})
		if GetFFlagRealtimeChanges() then
			self.DragContext = nil
		else
			self.Preview = nil
		end
	end

	self.onSelectDragStarted = function(input)
		if not self.state.showContextMenu then
			self.updateSelectDragStart(input.Position)
			self.updateSelectDragEnd(input.Position)
			self:setState({
				draggingSelection = true,
			})
		end
	end

	self.onSelectDragMoved = function(input)
		local props = self.props
		local position = input.Position
		self.updateSelectDragEnd(position)
		local dragStart = self.selectDragStart:getValue()
		local selectedKeyframes = props.SelectedKeyframes
		local minPos = Vector2.new(math.min(position.X, dragStart.X), math.min(position.Y, dragStart.Y))
		local maxPos = Vector2.new(math.max(position.X, dragStart.X), math.max(position.Y, dragStart.Y))
		-- Determine padding for selection
		local startFrame = props.StartFrame
		local endFrame = props.EndFrame
		local trackWidth = self.state.AbsoluteSize.X - props.TrackPadding
		local timelineScale = trackWidth / (endFrame - startFrame)
		local selectionPadding = Vector2.new(timelineScale / 2, Constants.TRACK_HEIGHT / 2)
		-- Find extents of selection
		local minFrame = self.getFrameFromPosition(minPos + selectionPadding)
		local minTrack = self.getTrackFromPosition(minPos + selectionPadding)
		local maxFrame = self.getFrameFromPosition(maxPos - selectionPadding)
		local maxTrack = self.getTrackFromPosition(maxPos - selectionPadding)

		local lastMinFrame = self.lastMinFrame or minFrame
		local lastMinTrack = self.lastMinTrack or minTrack
		local lastMaxFrame = self.lastMaxFrame or maxFrame
		local lastMaxTrack = self.lastMaxTrack or maxTrack

		if not isEmpty(selectedKeyframes)
			and (minFrame > lastMinFrame or minTrack > lastMinTrack
			or maxFrame < lastMaxFrame or maxTrack < lastMaxTrack) then
			props.DeselectAllKeyframes()
		end

		for trackIndex, track in ipairs(self.tracks) do
			if trackIndex >= minTrack and trackIndex <= maxTrack then
				if track.Keyframes then
					TrackUtils.traverseFrameRange(track.Keyframes, minFrame, maxFrame, function(frame)
						props.SelectKeyframe(track.Instance, track.Name, frame, true)
					end)
				end
			end
		end

		-- If top-level summary keyframes are part of the selection, select all keyframes beneath.
		if minTrack == 0 then
			local summaryKeyframes = TrackUtils.getSummaryKeyframes(self.tracks, minFrame, maxFrame)
			if #summaryKeyframes > 0 then
				TrackUtils.traverseFrameRange(summaryKeyframes, minFrame, maxFrame, function(frame)
					props.SelectKeyframesAtFrame(frame, true)
				end)
			end
		end

		self.lastMinFrame = minFrame
		self.lastMinTrack = minTrack
		self.lastMaxFrame = maxFrame
		self.lastMaxTrack = maxTrack
	end

	self.onSelectDragEnded = function()
		self:setState({
			draggingSelection = Roact.None,
		})
		self.updateSelectDragStart(nil)
		self.updateSelectDragEnd(nil)
		self.lastMinFrame = nil
		self.lastMinTrack = nil
		self.lastMaxFrame = nil
		self.lastMaxTrack = nil
	end

	self.recalculateExtents = function(rbx)
		self:setState({
			AbsoluteSize = rbx.AbsoluteSize,
			AbsolutePosition = rbx.AbsolutePosition,
		})
	end

	self.onEasingItemSelected = function(enumName, item)
		local newData = {
			[enumName] = item,
		}
		self.props.SetSelectedKeyframeData(newData)
	end

	self.showMenu = function()
		self.props.SetIsPlaying(false)
		self:setState({
			showContextMenu = true,
		})
	end

	self.hideMenu = function()
		self:setState({
			showContextMenu = false,
		})
	end

	self.setRenamingKeyframe = function(frame)
		self:setState({
			renamingKeyframe = frame or Roact.None,
		})
	end

	self.setChangingDuration = function(changing)
		self:setState({
			changingDuration = changing or Roact.None,
		})
	end

	self.setSelectedKeyframeDuration = function(textInput)
		self.setChangingDuration()
		local newLength = StringUtils.parseTime(textInput, self.props.AnimationData.Metadata.FrameRate)
		if newLength ~= nil then
			local earliest, latest = self:getSelectedKeyframesExtents()
			local currentLength = latest - earliest
			local scale = newLength / currentLength
			self.props.ScaleSelectedKeyframes(earliest, scale)
		end
	end
end

function DopeSheetController:hasSelectedKeyframes()
	if GetFFlagRealtimeChanges() then
		-- TODO: doesn't matter if we use selectedKeyframes or DragContext selectedKeyframes
		local selection = self.DragContext and self.DragContext.selectedKeyframe or self.props.SelectedKeyframes
		return selection ~= nil and not isEmpty(selection)
	else
		return self.props.SelectedKeyframes ~= nil and not isEmpty(self.props.SelectedKeyframes)
	end
end

function DopeSheetController:multipleFramesSelected()
	if GetFFlagRealtimeChanges() then
		-- Use Preview reference data and selection, if available
		local data = self.DragContext and self.DragContext.animationData or self.props.AnimationData
		local selection = self.DragContext and self.DragContext.selectedKeyframes or self.props.SelectedKeyframes

		local earliest, latest = AnimationData.getSelectionBounds(data, selection)
		return selection and earliest ~= latest
	else
		local earliest, latest = Preview.getFrameBounds(self.props.AnimationData, self.props.SelectedKeyframes)
		return self.props.SelectedKeyframes and earliest ~= latest
	end
end

function DopeSheetController:getSelectedKeyframesExtents()
	if GetFFlagRealtimeChanges() then
		return AnimationData.getSelectionBounds(self.props.AnimationData, self.props.SelectedKeyframes)
	else
		local earliest, latest = Preview.getFrameBounds(self.props.AnimationData, self.props.SelectedKeyframes)
		return earliest, latest
	end
end

function DopeSheetController:handleTimelineInputBegan(input, keysHeld)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if Input.isMultiSelectKey(input.KeyCode) then
			-- Start multi selecting on ctrl hold
			self.isMultiSelecting = true
		elseif Input.isDeleteKey(input.KeyCode) then
			self.props.DeleteSelectedKeyframes(self.props.Analytics)
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.props.DeselectAllKeyframes()
		self.mouseDownInTimeline = true
		self.onSelectDragStarted(input)
	end
end

function DopeSheetController:handleTimelineInputEnded(input)
	-- Stop multi selecting on ctrl release
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if Input.isMultiSelectKey(input.KeyCode) then
			self.isMultiSelecting = false
		end

	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.mouseDownInTimeline = false

	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local track = self.tracks[self.getTrackFromPosition(input.Position)]
		self.props.SetRightClickContextInfo({
			Frame = self.getFrameFromPosition(input.Position),
			TrackName = track and track.Name or nil,
			TrackType = GetFFlagFacialAnimationSupport() and (track and track.Type) or nil,
			InstanceName = track and track.Instance or nil,
		})
		self.showMenu()
	end
end

function DopeSheetController:handleKeyframeRightClick(instance, track, frame, selected)
	local rightClickInfo = {
		Frame = frame,
		OnKeyframe = true,
	}
	if isEmpty(self.props.SelectedKeyframes) then
		if instance == nil then
			-- User selected a summary keyframe
			self.props.SelectKeyframesAtFrame(frame)
		else
			self.props.SelectKeyframe(instance, track, frame, false)
		end
	end
	if instance == nil then
		rightClickInfo.SummaryKeyframe = frame
	end
	self.props.SetRightClickContextInfo(rightClickInfo)
	self.showMenu()
end

function DopeSheetController:handleKeyframeInputBegan(instance, track, frame, selected, input)
	-- Select keyframe if not selected
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.mouseDownOnKeyframe = true

		if selected then
			-- Deselect keyframe if it is clicked again when multi-selecting
			if self.isMultiSelecting then
				if instance then
					self.props.DeselectKeyframe(instance, track, frame)
				else
					self.props.DeselectKeyframesAtFrame(frame, self.isMultiSelecting)
				end
			end
		else
			if instance then
				self.props.SelectKeyframe(instance, track, frame, self.isMultiSelecting)
			else
				self.props.SelectKeyframesAtFrame(frame, self.isMultiSelecting)
			end
		end
	end
end

function DopeSheetController:handleKeyframeInputEnded(frame, selected, input)
	-- Start dragging if the mouse drags outside the keyframe
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if selected and self.mouseDownOnKeyframe then
			self.onKeyframeDragStarted(frame)
			self.onKeyframeDragMoved(input)
			self.mouseDownOnKeyframe = false
		end
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		self.mouseDownOnKeyframe = false
	end
end

-- Convert the AnimationData table into an array of tracks.
function DopeSheetController:makeTracks()
	local props = self.props
	local data = props.AnimationData

	local storeTracks = props.Tracks
	local newTracks = {}

	for index, track in ipairs(storeTracks) do
		newTracks[index] = Cryo.Dictionary.join(track)
		if data then
			for _, instance in pairs(data.Instances) do
				for trackName, trackData in pairs(instance.Tracks) do
					if track.Name == trackName then
						newTracks[index].Keyframes = trackData.Keyframes
						newTracks[index].Data = trackData.Data
					end
				end
			end
		end
	end

	return newTracks
end

-- Improve performance by only re-rendering when we need to
function DopeSheetController:shouldUpdate(nextProps, nextState)
	if nextState ~= self.state then
		return true
	end
	for k, _ in pairs(nextProps) do
		if nextProps[k] ~= self.props[k] then
			return true
		end
	end
	return false
end

function DopeSheetController:render()
		local props = self.props
		local state = self.state
		local dragFrame = state.dragFrame
		local dragging = state.dragging
		local draggingScale = state.draggingScale
		local draggingSelection = state.draggingSelection
		local absoluteSize = state.AbsoluteSize
		local absolutePosition = state.AbsolutePosition
		local showContextMenu = state.showContextMenu
		local renamingKeyframe = state.renamingKeyframe
		local changingDuration = state.changingDuration

		local active = props.Active
		local animationData = props.AnimationData
		local selectedKeyframes = props.SelectedKeyframes
		local startFrame = props.StartFrame
		local endFrame = props.EndFrame
		local trackPadding = props.TrackPadding
		local topTrackIndex = props.TopTrackIndex
		local showEvents = props.ShowEvents
		local localization = self.props.Localization

		local namedKeyframes = animationData and animationData.Events
			and animationData.Events.NamedKeyframes or {}

		local quantizeWarningText = localization:getText("Toast", "QuantizeWarning")
		local frameRate = animationData and animationData.Metadata and animationData.Metadata.FrameRate
		if frameRate and frameRate > Constants.MAX_FRAMERATE then
			quantizeWarningText = localization:getText("Toast", "MaxFramerateWarning")
		end

		local showQuantizeWarning = props.QuantizeWarning
			and not AnimationData.isQuantized(animationData)
		local loadedAnimName = props.Loaded
		local savedAnimName = props.Saved
		local showClippedWarning = props.ClippedWarning
		local showInvalidIdWarning = GetFFlagAddImportFailureToast() and props.InvalidIdWarning
		local showLoadToast = not GetFFlagHideLoadToastIfAnimationClipped() or (GetFFlagHideLoadToastIfAnimationClipped() and not showClippedWarning)

		local size = props.Size
		local position = props.Position

		local multipleSelected = self:hasSelectedKeyframes() and self:multipleFramesSelected()
		local currentDuration
		if changingDuration then
			local earliest, latest = self:getSelectedKeyframesExtents()
			currentDuration = latest - earliest
		end

		self.tracks = self:makeTracks()

		if animationData and animationData.Instances.Root then
			return Roact.createElement("Frame", {
				Size = size,
				Position = position,
				BackgroundTransparency = 1,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Events = showEvents and Roact.createElement(EventsController, {
					AbsolutePosition = absolutePosition - Vector2.new(0, Constants.TRACK_HEIGHT),
					AbsoluteSize = Vector2.new(absoluteSize.X, Constants.TRACK_HEIGHT),
					AnimationData = animationData,
					StartFrame = startFrame,
					EndFrame = endFrame,
					TrackPadding = trackPadding,
				}),

				DopeSheetContainer = Roact.createElement("Frame", {
					Size = showEvents and UDim2.new(1, 0, 1, -Constants.TRACK_HEIGHT) or UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					ClipsDescendants = true,
					[Roact.Change.AbsoluteSize] = self.recalculateExtents,
					[Roact.Event.InputBegan] = function(_, input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then
							self:handleTimelineInputBegan(input)
						end
					end,
					[Roact.Event.InputEnded] = function(_, input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then
							self:handleTimelineInputEnded(input)
						end
					end,
				}, {
					KeyboardListener = Roact.createElement(KeyboardListener, {
						OnKeyPressed = function(input, keysHeld)
							self:handleTimelineInputBegan(input, keysHeld)
						end,
						OnKeyReleased = function(input)
							self:handleTimelineInputEnded(input)
						end,
					}),

					DopeSheet = Roact.createElement(DopeSheet, {
						Size = UDim2.new(1, 0, 1, 0),
						ParentSize = absoluteSize,
						Padding = props.TrackPadding,
						StartFrame = startFrame,
						EndFrame = endFrame,
						TopTrackIndex = topTrackIndex,
						SelectedKeyframes = props.SelectedKeyframes,
						SelectedEvents = props.SelectedEvents,
						-- These two are undefined
						OnKeyframeSelected = not GetFFlagRealtimeChanges() and self.selectKeyframe or nil,
						OnKeyframeDragStarted = not GetFFlagRealtimeChanges() and self.onDragStarted or nil,
						--
						Tracks = self.tracks,
						-- Not needed anymore, since the store is updated in real time
						PreviewKeyframes = not GetFFlagRealtimeChanges() and self.Preview and self.Preview.previewKeyframes or nil,
						PreviewData = not GetFFlagRealtimeChanges() and self.Preview and self.Preview.previewData or nil,
						NamedKeyframes = namedKeyframes,
						ShowLegacyKeyframes = showQuantizeWarning,
						DragFrame = dragFrame,
						TrackHeight = Constants.TRACK_HEIGHT,
						SummaryTrackHeight = Constants.SUMMARY_TRACK_HEIGHT,
						ZIndex = 1,

						OnKeyRightClick = function(instance, track, frame, selected)
							self:handleKeyframeRightClick(instance, track, frame, selected)
						end,

						OnKeyInputBegan = function(instance, track, frame, selected, input)
							self:handleKeyframeInputBegan(instance, track, frame, selected, input)
						end,

						OnKeyInputEnded = function(frame, selected, input)
							self:handleKeyframeInputEnded(frame, selected, input)
						end,
					}),

					DragTarget = dragging and Roact.createElement(DragTarget, {
						OnDragMoved = self.onKeyframeDragMoved,
						OnDragEnded = self.onKeyframeDragEnded,
					}),

					MultiSelectBox = draggingSelection and Roact.createElement(SelectionBox, {
						OnDragMoved = self.onSelectDragMoved,
						OnDragEnded = self.onSelectDragEnded,
						SelectionStart = self.selectDragStart,
						SelectionEnd = self.selectDragEnd,
						SourceExtents = Rect.new(absolutePosition, absolutePosition + absoluteSize)
					}),

					TimelineActions = active and Roact.createElement(TimelineActions, {
						ShowMenu = showContextMenu,
						MultipleSelected = multipleSelected,
						OnMenuOpened = self.hideMenu,
						OnItemSelected = self.onEasingItemSelected,
						OnRenameKeyframe = function(frame)
							-- The prompt was sometimes not displaying when not using spawn
							spawn(function()
								self.setRenamingKeyframe(frame)
							end)
						end,
						OnChangeDuration = function()
							spawn(function()
								self.setChangingDuration(true)
							end)
						end,
					}),

					ScaleControls = multipleSelected and not draggingSelection and Roact.createElement(ScaleControls, {
						SelectedKeyframes = selectedKeyframes,
						PreviewKeyframes = not GetFFlagRealtimeChanges() and (self.Preview and self.Preview.previewKeyframes) or nil,
						StartFrame = startFrame,
						EndFrame = endFrame,
						TopTrackIndex = topTrackIndex,
						Tracks = self.tracks,
						TrackPadding = trackPadding,
						Dragging = draggingScale or dragging,
						ShowAsSeconds = true,
						FrameRate = animationData and animationData.Metadata and animationData.Metadata.FrameRate,
						DopeSheetWidth = absoluteSize.X - props.TrackPadding,
						ZIndex = 2,
						ShowSelectionArea = true,
						OnScaleHandleDragStart = self.onScaleHandleDragStarted,
						OnScaleHandleDragEnd = self.onScaleHandleDragEnded,
						OnScaleHandleDragMoved = self.onScaleHandleDragMoved,
					}),

					RenameKeyframePrompt = renamingKeyframe ~= nil and Roact.createElement(TextEntryPrompt, {
						PromptText = localization:getText("ContextMenu", "RenameKeyframe"),
						InputText = localization:getText("Menu", "RenameKeyframePrompt"),
						Text = namedKeyframes[renamingKeyframe] or Constants.DEFAULT_KEYFRAME_NAME,
						Buttons = {
							{Key = "Delete", Text = localization:getText("Dialog", "Delete")},
							{Key = false, Text = localization:getText("Dialog", "Cancel")},
							{Key = true, Text = localization:getText("Dialog", "Save"), Style = "Primary"},
						},
						OnButtonClicked = function(key)
							if key == "Delete" then
								self.setRenamingKeyframe()
								props.RenameKeyframe(renamingKeyframe, Constants.DEFAULT_KEYFRAME_NAME, props.Analytics)
							end
						end,
						OnTextSubmitted = function(text)
							self.setRenamingKeyframe()
							props.RenameKeyframe(renamingKeyframe, text, props.Analytics)
						end,
						OnClose = self.setRenamingKeyframe,
					}),

					ChangeDurationPrompt = currentDuration and Roact.createElement(TextEntryPrompt, {
						PromptText = localization:getText("Title", "ChangeDuration"),
						InputText = localization:getText("Title", "NewDuration"),
						NoticeText = localization:getText("Title", "CurrentDuration_Migrated", {currentDuration = currentDuration}),
						Text = currentDuration,
						Buttons = {
							{Key = false, Text = localization:getText("Dialog", "Cancel")},
							{Key = true, Text = localization:getText("Dialog", "Save"), Style = "Primary"},
						},
						OnTextSubmitted = self.setSelectedKeyframeDuration,
						OnClose = self.setChangingDuration,
					}),

					QuantizeToast = showQuantizeWarning and Roact.createElement(ActionToast, {
						Text = quantizeWarningText,
						ButtonWidth = Constants.PROMPT_BUTTON_SIZE.X * 1.5,
						Buttons = {
							{Key = true, Text = localization:getText("Toast", "AlignNow"), Style = "Round"},
							{Key = false, Text = localization:getText("Toast", "IgnoreWarning"), Style = "Round"},
						},
						OnButtonClicked = function(didQuantize)
							if didQuantize then
								props.QuantizeKeyframes()
							end
							props.CloseQuantizeWarning()
							props.Analytics:report("onQuantizeSelection", didQuantize)
						end,
					}),

					ClippedToast = showClippedWarning and Roact.createElement(NoticeToast, {
						Text = localization:getText("Toast", "ClippedWarning"),
						OnClose = props.CloseClippedToast,
					}),

					SavedToast = savedAnimName and Roact.createElement(NoticeToast, {
						Text = localization:getText("Toast", "Saved_Migrated", {savedAnimName = savedAnimName}),
						OnClose = props.CloseSavedToast,
					}),

					LoadedToast = showLoadToast and loadedAnimName and Roact.createElement(NoticeToast, {
						Text = localization:getText("Toast", "Loaded_Migrated", {loadedAnimName = loadedAnimName}),
						OnClose = props.CloseLoadedToast,
					}),

					InvalidId = showInvalidIdWarning and Roact.createElement(NoticeToast, {
						Text = localization:getText("Toast", "InvalidAnimation"),
						OnClose = props.CloseInvalidAnimationToast,
					})
				})
			})
		else
			return Roact.createElement("Frame", {
				Size = size,
				Position = position,
				BackgroundTransparency = 1,
				[Roact.Change.AbsoluteSize] = self.recalculateExtents,
			})
		end
end

ContextServices.mapToProps(DopeSheetController, {
	Localization = ContextServices.Localization,
	Theme = ContextServices.Theme,
	Analytics = ContextServices.Analytics
})

local function mapStateToProps(state, props)
	local status = state.Status

	local stateToProps = {
		Active = status.Active,
		SelectedKeyframes = status.SelectedKeyframes,
		Clipboard = status.Clipboard,
		AnimationData = state.AnimationData,
		QuantizeWarning = state.Notifications.QuantizeWarning,
		Saved = state.Notifications.Saved,
		Loaded = state.Notifications.Loaded,
		ClippedWarning = state.Notifications.ClippedWarning,
	}

	if GetFFlagAddImportFailureToast() then
		stateToProps["InvalidIdWarning"] = state.Notifications.InvalidAnimation
	end

	return stateToProps
end

local function mapDispatchToProps(dispatch)
	local dispatchToProps = {
		AddWaypoint = function()
			dispatch(AddWaypoint())
		end,

		MoveSelectedKeyframes = function(pivotFrame, newFrame, dragContext)
			if not GetFFlagRealtimeChanges() then
				dispatch(AddWaypoint())
			end
			dispatch(MoveSelectedKeyframes(pivotFrame, newFrame, dragContext))
		end,

		ScaleSelectedKeyframes = function(pivotFrame, scale, dragContext)
			if not GetFFlagRealtimeChanges() then
				dispatch(AddWaypoint())
			end
			dispatch(ScaleSelectedKeyframes(pivotFrame, scale, dragContext))
		end,

		DeselectKeyframe = function(instanceName, trackName, frame)
			dispatch(DeselectKeyframe(instanceName, trackName, frame))
		end,

		SelectKeyframe = function(instanceName, trackName, frame, multiSelect)
			dispatch(SetSelectedEvents({}))
			dispatch(SelectKeyframe(instanceName, trackName, frame, multiSelect))
		end,

		SelectKeyframesAtFrame = function(frame, multiSelect)
			dispatch(SetSelectedEvents({}))
			dispatch(SelectKeyframesAtFrame(frame, multiSelect))
		end,

		DeselectKeyframesAtFrame = function(frame, multiSelect)
			dispatch(DeselectKeyframesAtFrame(frame, multiSelect))
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

		SetRightClickContextInfo = function(info)
			dispatch(SetRightClickContextInfo(info))
		end,

		SetSelectedKeyframeData = function(newData)
			dispatch(AddWaypoint())
			dispatch(SetSelectedKeyframeData(newData))
		end,

		RenameKeyframe = function(frame, name, analytics)
			dispatch(AddWaypoint())
			dispatch(RenameKeyframe(frame, name, analytics))
		end,

		QuantizeKeyframes = function()
			dispatch(AddWaypoint())
			dispatch(QuantizeKeyframes())
		end,

		CloseQuantizeWarning = function()
			dispatch(SetNotification("QuantizeWarning", false))
		end,

		CloseSavedToast = function()
			dispatch(SetNotification("Saved", false))
		end,

		CloseLoadedToast = function()
			dispatch(SetNotification("Loaded", false))
		end,

		SetIsPlaying = function(isPlaying)
			dispatch(SetIsPlaying(isPlaying))
		end,

		CloseClippedToast = function()
			dispatch(SetNotification("ClippedWarning", false))
		end,
	}

	if GetFFlagAddImportFailureToast() then
		dispatchToProps["CloseInvalidAnimationToast"] = function()
			dispatch(SetNotification("InvalidAnimation", false))
		end
	end

	return dispatchToProps
end

return RoactRodux.connect(mapStateToProps,
	mapDispatchToProps)(DopeSheetController)
