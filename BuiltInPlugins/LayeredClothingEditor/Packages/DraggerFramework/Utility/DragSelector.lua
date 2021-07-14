local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent

local SelectionHelper = require(DraggerFramework.Utility.SelectionHelper)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)

-- Minimum distance (pixels) required for a drag to select parts.
local DRAG_SELECTION_THRESHOLD = 3

local DragSelector = {}
DragSelector.__index = DragSelector

function DragSelector.new(selectionWrapper, beginBoxSelect, endBoxSelect)
	assert(selectionWrapper ~= nil)
	assert(beginBoxSelect ~= nil)
	assert(endBoxSelect ~= nil)
	local self = {
		_isDragging = false,
		_selectionBeforeDrag = {},
		_dragStartLocation = nil,
		_dragCandidates = {},
		_selectionWrapper = selectionWrapper,
		_beginBoxSelect = beginBoxSelect,
		_endBoxSelect = endBoxSelect,
		_insertionOrder = {},
		_insertionOrderNext = 1,
	}

	return setmetatable(self, DragSelector)
end

-- Create a frustum described by the selection start and end locations and current camera.
local function getSelectionFrustum(draggerContext, startLocation, endLocation)
	local rect = Rect.new(startLocation, endLocation)

	local topLeft = draggerContext:viewportPointToRay(Vector2.new(rect.Min.X, rect.Min.Y))
	local topRight = draggerContext:viewportPointToRay(Vector2.new(rect.Max.X, rect.Min.Y))
	local bottomRight = draggerContext:viewportPointToRay(Vector2.new(rect.Max.X, rect.Max.Y))
	local bottomLeft = draggerContext:viewportPointToRay(Vector2.new(rect.Min.X, rect.Max.Y))

	if topRight.Direction:FuzzyEq(topLeft.Direction) then
		-- Ortho view
		local top = (topRight.Origin - topLeft.Origin):Cross(topRight.Direction)
		local right = (bottomRight.Origin - topRight.Origin):Cross(bottomRight.Direction)
		local bottom = (bottomLeft.Origin - bottomRight.Origin):Cross(bottomLeft.Direction)
		local left = (topLeft.Origin - bottomLeft.Origin):Cross(topLeft.Direction)

		return {
			{origin = topLeft.Origin, normal = top},
			{origin = topRight.Origin, normal = right},
			{origin = bottomRight.Origin, normal = bottom},
			{origin = bottomLeft.Origin, normal = left}
		}
	else
		-- Perspective view
		local left = bottomLeft.Direction:Cross(topLeft.Direction)
		local top = topLeft.Direction:Cross(topRight.Direction)
		local right = topRight.Direction:Cross(bottomRight.Direction)
		local bottom = bottomRight.Direction:Cross(bottomLeft.Direction)

		return {
			{origin = topLeft.Origin, normal = top},
			{origin = topRight.Origin, normal = right},
			{origin = bottomRight.Origin, normal = bottom},
			{origin = bottomLeft.Origin, normal = left}
		}
	end
end

function DragSelector:getStartLocation()
	return self._dragStartLocation
end

-- Get list of drag candidates from all selectable parts in the workspace.
-- startLocation can override the location the drag is treated as having
-- started at.
function DragSelector:beginDrag(draggerContext, startLocation)
	assert(not self._isDragging, "Cannot begin drag when already dragging.")
	self._isDragging = true

	self._dragCandidates = self._beginBoxSelect(draggerContext)
	self._selectionBeforeDrag = self._selectionWrapper:get()
	self._dragStartLocation = startLocation or draggerContext:getMouseLocation()
end

--[[
	Test selectable parts against the frustum defined by the drag start location
	and passed in location. Parts within the frustum are added or removed from
	the selection, based on the held modified keys.
]]
function DragSelector:updateDrag(draggerContext)
	assert(self._isDragging, "Cannot update drag when no drag in progress.")

	local shouldXorSelection = draggerContext:shouldExtendSelection()
	local shouldDrillSelection = draggerContext:isAltKeyDown()
	local location = draggerContext:getMouseLocation()

	local screenMovement = location - self._dragStartLocation
	if screenMovement.Magnitude < DRAG_SELECTION_THRESHOLD then
		return
	end

	local planes = getSelectionFrustum(draggerContext,
		self._dragStartLocation, location)
	if not planes then
		return
	end

	local newSelection = {}
	local didChangeSelection = false
	local insertionOrder = self._insertionOrder
	for _, candidate in ipairs(self._dragCandidates) do
		local inside = true
		for _, plane in ipairs(planes) do
			local dot = (candidate.Center - plane.origin):Dot(plane.normal)
			if dot < 0 then
				inside = false
				break
			end
		end
		if inside ~= candidate.Selected then
			candidate.Selected = inside
			didChangeSelection = true
			if getEngineFeatureModelPivotVisual() and inside then
				insertionOrder[candidate.Selectable] = self._insertionOrderNext
				self._insertionOrderNext += 1
			end
		end
		if inside then
			table.insert(newSelection, candidate.Selectable)
		end
	end

	if didChangeSelection then
		if getEngineFeatureModelPivotVisual() then
			table.sort(newSelection, function(a, b)
				return (insertionOrder[a] or 0) < (insertionOrder[b] or 0)
			end)
		end

		newSelection = SelectionHelper.updateSelectionWithMultipleSelectables(
			newSelection, self._selectionBeforeDrag,
			shouldXorSelection)
		self._selectionWrapper:set(newSelection)
	end
end

function DragSelector:commitDrag(draggerContext)
	self:updateDrag(draggerContext)

	self._endBoxSelect(draggerContext)

	self._selectionBeforeDrag = {}
	self._dragStartLocation = nil
	self._isDragging = false
end

return DragSelector
