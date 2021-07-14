local DraggerFramework = script.Parent.Parent.Parent
local Packages = DraggerFramework.Parent

local Roact = require(Packages.Roact)
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local AnimatedHoverBox = require(DraggerFramework.Components.AnimatedHoverBox)
local LocalSpaceIndicator = require(DraggerFramework.Components.LocalSpaceIndicator)
local SelectionHelper = require(DraggerFramework.Utility.SelectionHelper)
local getGeometry = require(DraggerFramework.Utility.getGeometry)
local getFaceInstance = require(DraggerFramework.Utility.getFaceInstance)
local HoverTracker = require(DraggerFramework.Implementation.HoverTracker)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local Ready = {}
Ready.__index = Ready

function Ready.new(draggerToolModel)
	return setmetatable({
		_draggerToolModel = draggerToolModel
	}, Ready)
end

function Ready:enter()
	local function onHoverExternallyChanged()
		self._draggerToolModel:_processViewChanged()
	end
	self._hoverTracker =
		HoverTracker.new(
			self._draggerToolModel:getSchema(),
			self._draggerToolModel:getHandlesList(),
			onHoverExternallyChanged)
	self:_updateHoverTracker()
end

function Ready:leave()
	self._hoverTracker:clearHover(self._draggerToolModel._draggerContext)
end

function Ready:render()
	local elements = {}

	local draggerContext = self._draggerToolModel._draggerContext

	local hoverSelectable = self._hoverTracker:getHoverSelectable()
	if draggerContext:shouldShowHover() and hoverSelectable then
		-- Calls to the schema to know what kind of component to render the
		-- selection box for the hovered object with.
		local component = self._draggerToolModel:getSchema().getSelectionBoxComponent(
			draggerContext, hoverSelectable)
		if component then
			local animatePeriod
			if draggerContext:shouldAnimateHover() then
				animatePeriod = draggerContext:getHoverAnimationSpeedInSeconds()
			end

			local isActive = false
			if draggerContext:shouldShowActiveInstanceHighlight() then
				local activeInstance =
					self._draggerToolModel:getSelectionWrapper():getActiveSelectable()
				isActive = (hoverSelectable == activeInstance)
			end

			elements.HoverBox = Roact.createElement(AnimatedHoverBox, {
				-- Configurable component to render the selection box
				SelectionBoxComponent = component,
				HoverTarget = hoverSelectable,
				SelectColor = draggerContext:getSelectionBoxColor(isActive),
				LineThickness = draggerContext:getHoverLineThickness(),
				HoverColor = draggerContext:getHoverBoxColor(isActive),
				AnimatePeriod = animatePeriod,
			})
		end
	end

	if hoverSelectable or self._hoverTracker:getHoverHandleId() then
		self._draggerToolModel:setMouseCursor(StandardCursor.getOpenHand())
	else
		self._draggerToolModel:setMouseCursor(StandardCursor.getArrow())
	end

	if self._draggerToolModel:shouldShowLocalSpaceIndicator() then
		local selectionInfo = self._draggerToolModel._selectionInfo
		if not selectionInfo:isEmpty() and draggerContext:shouldUseLocalSpace() then
			local cframe, offset, size = selectionInfo:getLocalBoundingBox()

			elements.LocalSpaceIndicator = Roact.createElement(LocalSpaceIndicator, {
				CFrame = cframe * CFrame.new(offset),
				Size = size,
				TextColor3 = draggerContext:getSelectionBoxColor(),
				DraggerContext = draggerContext,
			})
		end
	end

	local hoverHandles, hoverHandleId = self._hoverTracker:getHoverHandleId()
	for i, handles in pairs(self._draggerToolModel:getHandlesList()) do
		elements["ImplementationUI" .. i] =
			handles:render(hoverHandles == handles and hoverHandleId or nil)
	end

	return Roact.createFragment(elements)
end

function Ready:processSelectionChanged()
	-- We expect selection changes while in the ready state
	-- when the developer selects objects in the explorer window.
	self:_updateHoverTracker()
end

--[[
	Find the clicked part or constraint system gizmo by raycasting with the
	current mouse location and decide what action to take:

	* If the clicked instance is added to or was already in the selection, begin
	  (maybe) freeform dragging the selected parts.
	* If no selectable instance was clicked, begin drag selecting.
	* When an Attachment is clicked without a selection modifier key pressed,
	  begin (maybe) freeform dragging that Attachment.
	* When a Constraint is clicked, select it but don't do any form of drag.
]]
function Ready:processMouseDown(isDoubleClick)
	-- We have to do an update here for the edge case where the 3D view just
	-- became selected thanks to the mouse down event, so we haven't received
	-- a view change event yet.
	self:_updateHoverTracker()

	local hoverHandles, hoverHandleId = self._hoverTracker:getHoverHandleId()
	if hoverHandleId then
		self._draggerToolModel:transitionToState(DraggerStateType.DraggingHandle,
			hoverHandles, hoverHandleId)
	else
		self:_clickInWorld(isDoubleClick)
	end
end

function Ready:processViewChanged()
	self:_updateHoverTracker()
end

function Ready:processMouseUp()
	-- Nothing to do. This case can ocurr when the user clicks on a constraint.
end

function Ready:processKeyDown(keyCode)
	if getFFlagSummonPivot() then
		for _, handles in pairs(self._draggerToolModel:getHandlesList()) do
			if handles.keyDown then
				if handles:keyDown(keyCode) then
					self:processViewChanged()
					self._draggerToolModel:_scheduleRender()
				end
			end
		end
	end
end

function Ready:processKeyUp(keyCode)
	if getFFlagSummonPivot() then
		for _, handles in pairs(self._draggerToolModel:getHandlesList()) do
			if handles.keyUp then
				if handles:keyUp(keyCode) then
					self:processViewChanged()
					self._draggerToolModel:_scheduleRender()
				end
			end
		end
	end
end

function Ready:_updateHoverTracker()
	self._hoverTracker:update(
		self._draggerToolModel._draggerContext,
		self._draggerToolModel:getSelectionWrapper():get(),
		self._draggerToolModel._selectionInfo)
end

local function contains(list, targetItem)
	for _, item in ipairs(list) do
		if item == targetItem then
			return true
		end
	end
	return false
end

--[[
	Called when the user clicking in the 3d space (not on a handle)
]]
function Ready:_clickInWorld(isDoubleClick)
	local draggerContext = self._draggerToolModel._draggerContext
	local clickedItem, position = self._hoverTracker:getHoverItem()
	local clickedSelectable = self._hoverTracker:getHoverSelectable()
	local oldSelection = self._draggerToolModel:getSelectionWrapper():get()
	local selectionDidContainSelectable = contains(oldSelection, clickedSelectable)
	local shouldExtendSelection = draggerContext:shouldExtendSelection()
	if isDoubleClick and selectionDidContainSelectable then
		-- Special case. Double clicking with extend selection would be a
		-- no-op, thanks to adding something to the selection and then
		-- immediately removing it again.
		-- Prevent this. This also allows us to handle double clicks with
		-- shouldExtendSelection activated as a getNextSelectable invocation.
		shouldExtendSelection = false
	end
	local isExclusiveSelectable =
		(clickedSelectable ~= nil) and
		self._draggerToolModel:getSchema().isExclusiveSelectable(
			draggerContext, clickedSelectable, clickedItem)
	local selectionDidChange, newSelection, hint =
		SelectionHelper.updateSelection(
			clickedSelectable, oldSelection,
			isExclusiveSelectable,
			shouldExtendSelection)
	if selectionDidChange then
		self._draggerToolModel:getSelectionWrapper():set(newSelection, hint)

		-- Process selection changed only gets called automatically when studio
		-- changes the selection, since we just changed the selection manually
		-- we need to invoke it here.
		self._draggerToolModel:_processSelectionChanged()

		-- If we have objects to transform, then change the insert point to
		-- the selection's center. This makes it easier to paste and insert
		-- objects at the position of a target object.
		self._draggerToolModel:getSchema().setActivePoint(
			self._draggerToolModel._draggerContext,
			self._draggerToolModel._selectionInfo)
	end

	self._draggerToolModel:_analyticsSendClick(clickedItem, selectionDidChange)

	local selectionEvent = {
		DoubleClicked = isDoubleClick,
		ClickedSelectable = clickedSelectable,
		ClickedItem = clickedItem,
		ClickedPosition = position,
		SelectionDidContainSelectable = selectionDidContainSelectable,
		SelectionNowContainsSelectable = contains(newSelection, clickedSelectable),
	}
	local nextState, extraData =
		self._draggerToolModel:getSchema().dispatchWorldClick(
			self._draggerToolModel._draggerContext,
			self._draggerToolModel,
			selectionEvent)

	if nextState == "Ready" then
		if clickedSelectable and (not selectionDidChange or isDoubleClick) then
			self._draggerToolModel:transitionToState(
				DraggerStateType.PendingSelectNext, isDoubleClick, selectionEvent)
		else
			-- Nothing to do, stay in ready state
		end
	elseif nextState == "DragSelecting" then
		if self._draggerToolModel:doesAllowDragSelect() then
			self._draggerToolModel:transitionToState(DraggerStateType.DragSelecting)
		end
	elseif nextState == "FreeformSelectionDrag" then
		self._draggerToolModel:transitionToState(
			DraggerStateType.PendingDraggingParts, isDoubleClick, extraData)
	else
		error("Bad state returned from dispatchWorldClick: `" .. tostring(nextState) .. "`")
	end
end

return Ready