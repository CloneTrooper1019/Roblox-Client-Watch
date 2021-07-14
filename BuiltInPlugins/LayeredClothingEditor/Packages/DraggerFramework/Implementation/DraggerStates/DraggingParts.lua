local Workspace = game:GetService("Workspace")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local DraggerFramework = script.Parent.Parent.Parent

local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local DragHelper = require(DraggerFramework.Utility.DragHelper)
local PartMover = require(DraggerFramework.Utility.PartMover)
local AttachmentMover = require(DraggerFramework.Utility.AttachmentMover)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local DraggingParts = {}
DraggingParts.__index = DraggingParts

function DraggingParts.new(draggerToolModel, dragInfo)
	local t = tick()
	draggerToolModel._boundsChangedTracker:uninstall()
	local self = setmetatable({
		_draggerToolModel = draggerToolModel,
		_freeformDragger = draggerToolModel:getSchema().FreeformDragger.new(
			draggerToolModel._draggerContext, draggerToolModel, dragInfo)
	}, DraggingParts)
	local timeToStartDrag = tick() - t
	draggerToolModel:_analyticsRecordFreeformDragBegin(timeToStartDrag)
	return self
end

function DraggingParts:enter()
	self:_updateFreeformSelectionDrag()
end

function DraggingParts:leave()
end

function DraggingParts:_initIgnoreList(parts)
	local filter = table.create(#parts + 1)
	for i, part in ipairs(parts) do
		filter[i] = part
	end
	table.insert(filter, self._partMover:getIgnorePart())
	self._raycastFilter = filter
end

function DraggingParts:render()
	self._draggerToolModel:setMouseCursor(StandardCursor.getClosedHand())

	return self._freeformDragger:render()
end

function DraggingParts:processSelectionChanged()
	-- If something unexpectedly changes the selection out from underneath us,
	-- bail out of the drag.
	self:_endFreeformSelectionDrag()
end

function DraggingParts:processMouseDown()
	error("Mouse should already be down while dragging parts.")
end

function DraggingParts:processViewChanged()
	self:_updateFreeformSelectionDrag()
end

function DraggingParts:processMouseUp()
	self:_endFreeformSelectionDrag()
end

function DraggingParts:processKeyDown(keyCode)
	if keyCode == Enum.KeyCode.R then
		self._draggerToolModel._sessionAnalytics.dragRotates = self._draggerToolModel._sessionAnalytics.dragRotates + 1
		self:_tiltRotateFreeformSelectionDrag(Vector3.new(0, 1, 0))
	elseif keyCode == Enum.KeyCode.T then
		self._draggerToolModel._sessionAnalytics.dragTilts = self._draggerToolModel._sessionAnalytics.dragTilts + 1
		self:_tiltRotateFreeformSelectionDrag(Vector3.new(1, 0, 0))
	end
end

function DraggingParts:processKeyUp(keyCode)
end

function DraggingParts:_tiltRotateFreeformSelectionDrag(axis)
	self._freeformDragger:rotate(axis)

	self:_updateFreeformSelectionDrag()
	self._draggerToolModel:_scheduleRender()
end

function DraggingParts:_updateFreeformSelectionDrag()
	self._freeformDragger:update()
end

--[[
	Refresh selection info to reflect the new CFrames of the dragged parts
	and return to the Ready state.
]]
function DraggingParts:_endFreeformSelectionDrag()
	local newSelectionInfoHint = self._freeformDragger:destroy()

	self._draggerToolModel._boundsChangedTracker:install()

	self._draggerToolModel:_updateSelectionInfo(newSelectionInfoHint)

	self._draggerToolModel:transitionToState(DraggerStateType.Ready)

	self._draggerToolModel:getSchema().addUndoWaypoint(
		self._draggerToolModel._draggerContext,
		"End Freeform Drag")
	self._draggerToolModel:getSchema().setActivePoint(
		self._draggerToolModel._draggerContext,
		self._draggerToolModel._selectionInfo)
end

return DraggingParts