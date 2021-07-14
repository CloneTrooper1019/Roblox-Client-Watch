local DraggerFramework = script.Parent.Parent.Parent
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local FREEFORM_DRAG_THRESHOLD = 4

local PendingDraggingParts = {}
PendingDraggingParts.__index = PendingDraggingParts

function PendingDraggingParts.new(draggerToolModel, isDoubleClick, dragInfo)
	return setmetatable({
		_isDoubleClick = isDoubleClick,
		_dragStartLocation = draggerToolModel._draggerContext:getMouseLocation(),
		_dragInfo = dragInfo,
		_draggerToolModel = draggerToolModel
	}, PendingDraggingParts)
end

function PendingDraggingParts:enter()

end

function PendingDraggingParts:leave()

end

function PendingDraggingParts:render()
	self._draggerToolModel:setMouseCursor(StandardCursor.getClosedHand())
end

function PendingDraggingParts:processSelectionChanged()
	-- Don't clear the state back to Ready in this case. In Run mode the
	-- selection should change while we're sitting in Pending state, and
	-- that's okay, because we already recorded how to drag the selection
	-- relative to the mouse on down.
end

function PendingDraggingParts:processMouseDown()
	error("Mouse should already be down while pending part drag.")
end

function PendingDraggingParts:processViewChanged()
	local location = self._draggerToolModel._draggerContext:getMouseLocation()
	local screenMovement = location - self._dragStartLocation

	if screenMovement.Magnitude > FREEFORM_DRAG_THRESHOLD then
		self._draggerToolModel:transitionToState(DraggerStateType.DraggingParts, self._dragInfo)
	end
end

function PendingDraggingParts:processMouseUp()
	-- If the mouse didn't move enough to start a drag, try to select next
	-- selectables instead.
	self._draggerToolModel:selectNextSelectables(
		self._dragInfo, self._isDoubleClick)

	self._draggerToolModel:transitionToState(DraggerStateType.Ready)
end

function PendingDraggingParts:processKeyDown(keyCode)
	-- Nothing to do.
end

function PendingDraggingParts:processKeyUp(keyCode)
	-- Nothing to do.
end

return PendingDraggingParts