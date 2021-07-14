
local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local SelectionDot = require(DraggerFramework.Components.SelectionDot)
local Math = require(DraggerFramework.Utility.Math)
local SelectionWrapper = require(DraggerFramework.Utility.SelectionWrapper)
local SelectionHelper = require(DraggerFramework.Utility.SelectionHelper)
local classifyPivot = require(DraggerFramework.Utility.classifyPivot)

local getFFlagDraggerPerf = require(DraggerFramework.Flags.getFFlagDraggerPerf)
local getFFlagPivotAnalytics = require(DraggerFramework.Flags.getFFlagPivotAnalytics)
local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local DraggerToolModel = {}
DraggerToolModel.__index = DraggerToolModel

-- States
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local DraggerStates = DraggerFramework.Implementation.DraggerStates
local DraggerState = {
	[DraggerStateType.Ready] = require(DraggerStates.Ready),
	[DraggerStateType.DraggingFaceInstance] = require(DraggerStates.DraggingFaceInstance),
	[DraggerStateType.PendingDraggingParts] = require(DraggerStates.PendingDraggingParts),
	[DraggerStateType.PendingSelectNext] = require(DraggerStates.PendingSelectNext),
	[DraggerStateType.DraggingHandle] = require(DraggerStates.DraggingHandle),
	[DraggerStateType.DraggingParts] = require(DraggerStates.DraggingParts),
	[DraggerStateType.DragSelecting] = require(DraggerStates.DragSelecting),
}

-- We can't respect the OS setting, no way to tell whether a click in the 3d
-- viewport is a double click :(
local DOUBLE_CLICK_TIME = 0.5

-- Note: ShowSelectionDot remove because we don't use it anymore
-- Note: UseCollisionsTransparency is part of the Schema now
local DEFAULT_DRAGGER_SETTINGS = {
	AllowDragSelect = true,
	AllowFreeformDrag = true,
	ShowLocalSpaceIndicator = false,
	WasAutoSelected = false,
	HandlesList = {},
	ShowPivotIndicator = false,
}
local REQUIRED_DRAGGER_SETTINGS = {
	AnalyticsName = true,
}

function DraggerToolModel.new(draggerContext, draggerSchema, draggerSettings,
		requestRenderCallback, markViewDirtyCallback, markSelectionDirtyCallback)
	-- Check validity of passed set of props
	for prop, _ in pairs(draggerSettings) do
		if DEFAULT_DRAGGER_SETTINGS[prop] == nil and REQUIRED_DRAGGER_SETTINGS[prop] == nil then
			error("Unexpected DraggerToolModel prop `" .. prop .. "`")
		end
	end
	-- Build props for this dragger
	local draggerSettingsOrDefault = {}

	for requiredProp, _ in pairs(REQUIRED_DRAGGER_SETTINGS) do
		local settingValue = draggerSettings[requiredProp]
		if settingValue == nil then
			error("Required prop `" .. requiredProp .. "` missing from DraggerToolModel props")
		else
			draggerSettingsOrDefault[requiredProp] = settingValue
		end
	end
	for prop, default in pairs(DEFAULT_DRAGGER_SETTINGS) do
		if draggerSettings[prop] ~= nil then
			draggerSettingsOrDefault[prop] = draggerSettings[prop]
		else
			draggerSettingsOrDefault[prop] = default
		end
	end

	return setmetatable({
		_lastMouseClickTime = 0,
		_lastMouseClickLocation = Vector2.new(-1, -1),
		_handlesList = draggerSettingsOrDefault.HandlesList,
		_draggerContext = draggerContext,
		_draggerSchema = draggerSchema,
		_modelProps = draggerSettingsOrDefault,
		_requestRenderCallback = requestRenderCallback,
		_markViewDirtyCallback = markViewDirtyCallback,
		_markSelectionDirtyCallback = markSelectionDirtyCallback,
		_selectionWrapper = nil,
	}, DraggerToolModel)
end

--[[
	Called by the DraggerTool main states to set the mouse cursor.

	To not interfere with other parts of studio which set the mouse cursor,
	we have to only set the cursor when we think it should change. This is the
	abstraction layer that guarantees this.
]]
function DraggerToolModel:setMouseCursor(cursor)
	if self._mouseCursor ~= cursor then
		self._mouseCursor = cursor
		self._draggerContext:setMouseIcon(cursor)
	end
end

--[[
	Called by the main DraggerToolModel code, and the code in individual
	DraggerTool main states in order to transition to a new state.

	The variable arguments are passed as arguments to the constructor of the
	new state object which will be constructed and transitioned to.
]]
function DraggerToolModel:transitionToState(draggerStateType, ...)
	assert(DraggerState[draggerStateType], "Missing state type: "..tostring(draggerStateType))
	self._stateObject:leave()
	self._mainState = draggerStateType
	self._stateObject = DraggerState[draggerStateType].new(self, ...)
	self._stateObject:enter()
	self:_scheduleRender()
end

function DraggerToolModel:render()
	local selection = self._selectionWrapper:get()

	
	return Roact.createElement(Roact.Portal, {
		target = self._draggerContext:getGuiParent(),
	}, {
		DraggerUI = Roact.createElement("Folder", {}, self._stateObject:render()),
	})
end

-- Called every frame on render step
function DraggerToolModel:update()
	if self._draggerContext:isSimulating() then
		-- Must do a view update every frame in run mode to catch stuff
		-- moving under our mouse.
		self._markViewDirtyCallback()

		-- If there's a physically simulated part in the selection then we
		-- have to update the whole selection every frame.
		local isDragging =
			self._mainState == DraggerStateType.DraggingHandle or
			self._mainState == DraggerStateType.DraggingParts
		if not isDragging then
			if self._selectionInfo:isDynamic() then
				self._markSelectionDirtyCallback()
			end
		end
	end
end

function DraggerToolModel:getSelectionWrapper()
	return self._selectionWrapper
end

function DraggerToolModel:getAnalyticsName()
	return self._modelProps.AnalyticsName
end

-- Note: This needs to be exposed now because the Schema analytics care about it
function DraggerToolModel:wasAutoSelected()
	return self._modelProps.WasAutoSelected
end

function DraggerToolModel:getSchema()
	return self._draggerSchema
end

function DraggerToolModel:getHandlesList()
	return self._handlesList
end

function DraggerToolModel:doesAllowDragSelect()
	return self._modelProps.AllowDragSelect
end

function DraggerToolModel:doesAllowFreeformDrag()
	return self._modelProps.AllowFreeformDrag
end

function DraggerToolModel:shouldShowLocalSpaceIndicator()
	return self._modelProps.ShowLocalSpaceIndicator
end

function DraggerToolModel:shouldShowSelectionDot()
	return self._modelProps.ShowSelectionDot
end

function DraggerToolModel:shouldUseCollisionTransparency()
	return self._modelProps.UseCollisionsTransparency
end

function DraggerToolModel:shouldAlignDraggedObjects()
	return self._draggerContext:shouldAlignDraggedObjects()
end

function DraggerToolModel:selectNextSelectables(dragInfo, isDoubleClick)
	local oldSelection = self._selectionWrapper:get()
	local nextSelectables = self._draggerSchema.getNextSelectables(
		self._draggerContext,
		oldSelection,
		dragInfo,
		isDoubleClick)
	if nextSelectables then
		local shouldXorSelection = false
		local shouldExtendSelection = self._draggerContext:shouldExtendSelection()
		local newSelection =
			SelectionHelper.updateSelectionWithMultipleSelectables(
				nextSelectables, oldSelection, shouldXorSelection, shouldExtendSelection)
		self._selectionWrapper:set(newSelection)
		if getFFlagDraggerPerf() then
			self:_updateSelectionInfo()
		end
	end
	if not getFFlagDraggerPerf() then
		self:_updateSelectionInfo()
	end
end

--[[
Tries to boil what the pivot for the current selection is set to down to a
single descriptive analytics value as a string. Possible return values:
	- None: There is no selection
	- Default: The pivot is at the center of the bounds
	- Inside: The pivot is within (but not exactly on) the bounds
	- Surface: The pivot is exactly on the surface of the bounds
	- Outside: The pivot is outside of the bounds
	- Far: The pivot is very far outside the bounds (more than one size away)
]]
function DraggerToolModel:classifySelectionPivot()
	if not self._selectionInfo then
		return "None"
	end

	local cframe, offset, size = self._selectionInfo:getBoundingBox()
	return classifyPivot(cframe, offset, size)
end

function DraggerToolModel:_processSelected()
	self._mainState = DraggerStateType.Ready
	self._stateObject = DraggerState[DraggerStateType.Ready].new(self)

	if getFFlagSummonPivot() and self._modelProps.ShowPivotIndicator then
		self._oldShowPivot = self._draggerContext:setPivotIndicator(true)
	end

	self._mouseCursor = ""
	self._draggerContext:setMouseIcon("")

	-- We defer handling part bounds changes to the render step, as the
	-- changes that are happening to the selection may be happening to many
	-- objects in the selection. Without deferring we could end up with
	-- N^2 behavior if the whole selection is being updated (N part bounds
	-- changes x each bounds change requires looking at all N parts in
	-- the selection to calculate the new bounds)
	self._boundsChangedTracker =
		self._draggerSchema.BoundsChangedTracker.new(
			self._draggerContext,
			function(item)
				self._markSelectionDirtyCallback()
			end)
	self._boundsChangedTracker:install()

	self._selectionWrapper = SelectionWrapper.new(self._draggerContext:getSelection())
	self._selectionChangedConnection =
		self._selectionWrapper.onSelectionExternallyChanged:Connect(function()
			self:_processSelectionChanged()
		end)

	self:_updateSelectionInfo()

	self._stateObject:enter()

	self:_analyticsSessionBegin()
end

function DraggerToolModel:_processDeselected()
	if self._isMouseDown then
		self:_processMouseUp()
	end

	if getFFlagSummonPivot() and self._modelProps.ShowPivotIndicator then
		self._draggerContext:setPivotIndicator(self._oldShowPivot)
	end

	-- Need to explicitly leave the last state now for correct behavior
	self._stateObject:leave()
	self._stateObject = nil

	self._selectionWrapper:destroy()
	self._selectionWrapper = nil

	self._boundsChangedTracker:uninstall()

	self._selectionChangedConnection:Disconnect()
	self._selectionChangedConnection = nil

	self:_analyticsSendSession()
end

function DraggerToolModel:_processSelectionChanged()
	self:_updateSelectionInfo()
	self._stateObject:processSelectionChanged()
end

function DraggerToolModel:_processKeyDown(keyCode)
	self._stateObject:processKeyDown(keyCode)
end

function DraggerToolModel:_processKeyUp(keyCode)
	self._stateObject:processKeyUp(keyCode)
end

function DraggerToolModel:_processMouseDown()
	if self._isMouseDown then
		-- Not ideal code. There are just too many situations where the engine
		-- passes us disbalanced mouseup / mousedown events for us to reliably
		-- handle all of them, so as an escape hatch, handle a mouse up if we
		-- get a mouse down without having gotten the preceeding mouse up.
		self:_processMouseUp()
	end
	local isDoubleClick
	local thisClickLocation = self._draggerContext:getMouseLocation()
	if (os.clock() - self._lastMouseClickTime) < DOUBLE_CLICK_TIME and
		thisClickLocation == self._lastMouseClickLocation then
		isDoubleClick = true
		self._lastMouseClickTime = 0 -- Suppress double-double clicks
	else
		isDoubleClick = false
		self._lastMouseClickTime = os.clock()
	end
	self._lastMouseClickLocation = thisClickLocation
	self._isMouseDown = true
	self._stateObject:processMouseDown(isDoubleClick)
end

function DraggerToolModel:_processMouseUp()
	if not self._isMouseDown then
		-- There are various circumstances where the mouse can be down without
		-- us having started an associated drag. The engine has a habit of
		-- sending mismatched mouse up/down events in various rare edge cases.
		return
	end
	self._isMouseDown = false
	self._stateObject:processMouseUp()
end

--[[
	Called when the camera or mouse position changes, i.e., the world position
	currently under the mouse cursor has changed.
]]
function DraggerToolModel:_processViewChanged()
	self._stateObject:processViewChanged()

	-- Derived world state may have changed as a result of the view update, so
	-- we need to manually trigger a re-render here.
	self:_scheduleRender()
end

function DraggerToolModel:_updateSelectionInfo(newSelectionInfoHint)
	if getFFlagDraggerPerf() and newSelectionInfoHint then
		self._selectionInfo = newSelectionInfoHint
	else
		self._selectionInfo = self._draggerSchema.SelectionInfo.new(
			self._draggerContext, self._selectionWrapper:get())
	end
	self._boundsChangedTracker:setSelection(self._selectionInfo)

	self:_scheduleRender()

	if getFFlagSummonPivot() then
		self:_updatePivotIndicatorVisibility()
	end
end

function DraggerToolModel:_updatePivotIndicatorVisibility()
	if self._modelProps.ShowPivotIndicator then
		if #self._selectionWrapper:get() > 1 then
			self._draggerContext:setPivotIndicator(self._oldShowPivot)
		else
			self._draggerContext:setPivotIndicator(true)
		end
	end
end

function DraggerToolModel:_processToolboxInitiatedFreeformSelectionDrag()
	-- We didn't get an associated mouse down, so we have to set the mouse
	-- down tracking variable here.
	self._isMouseDown = true

	self:transitionToState(DraggerStateType.DraggingParts, {
		mouseLocation = self._draggerContext:getMouseLocation(),
		basisPoint = Vector3.new(), -- Just drag from the center of the object
		clickPoint = Vector3.new(),
	})
end

function DraggerToolModel:_processToolboxInitiatedFaceDrag(instances)
	-- We didn't get an associated mouse down, so we have to set the mouse
	-- down tracking variable here.
	self._isMouseDown = true

	local connectionToBreak
	if instances[1]:IsA("VideoFrame") then
		local videoFrameContainer = Instance.new("SurfaceGui")
		videoFrameContainer.Enabled = true
		videoFrameContainer.Parent = Workspace
		instances[1].Parent = videoFrameContainer

		-- When we the user drags out of the 3D view, the face instance that was
		-- passed to us will be removed. When that happens we need to also
		-- remove the container we made for it here.
		connectionToBreak = videoFrameContainer.ChildRemoved:Connect(function(instance)
			videoFrameContainer:Destroy()
		end)

		self._selectionWrapper:set({ videoFrameContainer })
		self:_updateSelectionInfo()
	end

	self:transitionToState(DraggerStateType.DraggingFaceInstance, connectionToBreak)
end

function DraggerToolModel:_scheduleRender()
	for _, handle in pairs(self._handlesList) do
		if handle.update then
			handle:update(self, self._selectionInfo)
		end
	end

	self._requestRenderCallback()
end

function DraggerToolModel:_analyticsSessionBegin()
	self._selectedAtTime = tick()
	self._sessionAnalytics = {
		freeformDrags = 0,
		handleDrags = 0,
		clickSelects = 0,
		dragSelects = 0,
		dragTilts = 0,
		dragRotates = 0,
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = self._modelProps.WasAutoSelected,
	}
	self._draggerContext:getAnalytics():sendEvent("toolSelected", {
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = self._modelProps.WasAutoSelected,
	})
	if self._modelProps.WasAutoSelected then
		self._draggerContext:getAnalytics():reportCounter("studioLuaDefaultDraggerSelected")
	else
		self._draggerContext:getAnalytics():reportCounter("studioLua" .. self._modelProps.AnalyticsName .. "DraggerSelected")
	end
end

function DraggerToolModel:_analyticsSendSession()
	local totalTime = tick() - self._selectedAtTime
	self._sessionAnalytics.duration = totalTime
	self._draggerContext:getAnalytics():sendEvent("toolSession", self._sessionAnalytics)
end

function DraggerToolModel:_analyticsSendClick(clickedInstance, didAlterSelection)
	self._draggerContext:getAnalytics():sendEvent("clickedObject", {
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = self._modelProps.WasAutoSelected,
		altPressed = self._draggerContext:isAltKeyDown(),
		ctrlPressed = self._draggerContext:isCtrlKeyDown(),
		shiftPressed = self._draggerContext:isShiftKeyDown(),
		clickedAttachment = clickedInstance and clickedInstance:IsA("Attachment"),
		clickedConstraint = clickedInstance and clickedInstance:IsA("Constraint"),
		clickedWeldConstraint = clickedInstance and clickedInstance:IsA("WeldConstraint"),
		clickedNoCollisionConstraint = clickedInstance and clickedInstance:IsA("NoCollisionConstraint"),
		didAlterSelection = didAlterSelection,
	})
	if didAlterSelection then
		self._sessionAnalytics.clickSelects = self._sessionAnalytics.clickSelects + 1
	end
end

function DraggerToolModel:_analyticsRecordFreeformDragBegin(timeToStartDrag)
	self._sessionAnalytics.freeformDrags = self._sessionAnalytics.freeformDrags + 1
	local dragStartTimeName =
		"studioLuaDragger" .. self._modelProps.AnalyticsName .. "DragTime"
	self._draggerContext:getAnalytics():reportStats(dragStartTimeName, timeToStartDrag)
end

function DraggerToolModel:_analyticsSendHandleDragged(handleId)
	self._draggerContext:getAnalytics():sendEvent("handleDragged", {
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = false, -- For consistency with other events
		gridSize = self._draggerContext:getGridSize(),
		rotateIncrement = self._draggerContext:getRotateIncrement(),
		useLocalSpace = self._draggerContext:shouldUseLocalSpace(),
		joinSurfaces = self._draggerContext:shouldJoinSurfaces(),
		useConstraints = self._draggerContext:areConstraintsEnabled(),
		haveCollisions = self._draggerContext:areCollisionsEnabled(),
		pivotType = getFFlagPivotAnalytics() and self:classifySelectionPivot() or nil,
		handleId = getFFlagPivotAnalytics() and handleId or nil,
	})
end

function DraggerToolModel:_analyticsSendBoxSelect()
	self._draggerContext:getAnalytics():sendEvent("boxSelected", {
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = self._modelProps.WasAutoSelected,
		objectCount = #self._selectionWrapper:get(), -- This line changed
		altPressed = self._draggerContext:isAltKeyDown(),
		ctrlPressed = self._draggerContext:isCtrlKeyDown(),
		shiftPressed = self._draggerContext:isShiftKeyDown(),
	})
end

function DraggerToolModel:_analyticsSendFaceInstanceSelected(className)
	self._draggerContext:getAnalytics():sendEvent("faceInstanceSelected", {
		toolName = self._modelProps.AnalyticsName,
		wasAutoSelected = self._modelProps.WasAutoSelected,
		className = className,
	})
end

return DraggerToolModel
