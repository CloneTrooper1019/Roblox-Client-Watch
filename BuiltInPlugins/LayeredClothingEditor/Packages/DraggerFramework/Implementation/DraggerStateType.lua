
local StateType = {}
setmetatable(StateType, {
	__index = function(self, index)
		error("Attempt to get invalid StateType `"..tostring(index).."`")
	end,
})

StateType.Ready = "Ready"
-- Clicked a part, but haven't started dragging:
StateType.PendingDraggingParts = "PendingDraggingParts"
-- No-op clicked the selection, when releasing the mouse, try to select next:
StateType.PendingSelectNext = "PendingSelectNext"
StateType.DraggingHandle = "DraggingHandle"
StateType.DraggingParts = "DraggingParts"
StateType.DragSelecting = "DragSelecting"
StateType.DraggingFaceInstance = "DraggingFaceInstance"

return StateType