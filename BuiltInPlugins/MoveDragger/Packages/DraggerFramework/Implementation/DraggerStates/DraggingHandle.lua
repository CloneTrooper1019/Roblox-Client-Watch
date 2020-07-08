if require(script.Parent.Parent.Parent.Flags.getFFlagDraggerRefactor)() then
	return require(script.Parent.DraggingHandle_Refactor)
end

local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent.Parent
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local SelectionHelper = require(DraggerFramework.Utility.SelectionHelper)
local setInsertPoint = require(DraggerFramework.Utility.setInsertPoint)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local NO_COLLISIONS_TRANSPARENCY = 0.4

local DraggingHandle = {}
DraggingHandle.__index = DraggingHandle

function DraggingHandle.new(draggerTool, makeDraggedPartsTransparent, draggingHandleId)
	local self = setmetatable({}, DraggingHandle)
	self:_init(draggerTool, makeDraggedPartsTransparent, draggingHandleId)
	return self
end

function DraggingHandle:enter(draggerTool)

end

function DraggingHandle:leave(draggerTool)

end

function DraggingHandle:_init(draggerTool, makeDraggedPartsTransparent, draggingHandleId)
	assert(draggingHandleId, "Missing draggingHandleId in DraggingHandle::_init")

	-- DEBUG: Allow designers to play with handle settings.
	-- Remove before shipping!
	if Workspace:FindFirstChild("NoCollisionsTransparency") and Workspace.NoCollisionsTransparency.Value ~= 0 then
		NO_COLLISIONS_TRANSPARENCY = 0.4 * Workspace.NoCollisionsTransparency.Value
	end

	draggerTool._sessionAnalytics.handleDrags = draggerTool._sessionAnalytics.handleDrags + 1
	draggerTool._boundsChangedTracker:uninstall()
	draggerTool.props.ToolImplementation:mouseDown(SelectionHelper.getMouseRay(), draggingHandleId)
	self._draggingHandleId = draggingHandleId

	self._draggingModifiedParts = {}
	self._makeDraggedPartsTransparent = makeDraggedPartsTransparent
	if makeDraggedPartsTransparent then
		for _, part in ipairs(draggerTool._derivedWorldState:getObjectsToTransform()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = NO_COLLISIONS_TRANSPARENCY
				table.insert(self._draggingModifiedParts, part)
			end
		end
	end
end

function DraggingHandle:render(draggerTool)
	draggerTool:setMouseCursor(StandardCursor.getClosedHand())

	local toolImplementation = draggerTool.props.ToolImplementation
	if toolImplementation and toolImplementation.render then
		return toolImplementation:render(self._draggingHandleId)
	end
end

function DraggingHandle:processSelectionChanged(draggerTool)
	-- Re-init the drag if the selection changes.
	self:_endHandleDrag(draggerTool)
	self:_init(draggerTool, self._makeDraggedPartsTransparent, self._draggingHandleId)
end

function DraggingHandle:processMouseDown(draggerTool)
	error("Mouse should already be down while dragging handle.")
end

function DraggingHandle:processViewChanged(draggerTool)
	draggerTool.props.ToolImplementation:mouseDrag(SelectionHelper.getMouseRay())
end

function DraggingHandle:processMouseUp(draggerTool)
	self:_endHandleDrag(draggerTool)
	draggerTool:transitionToState({}, DraggerStateType.Ready)
end

function DraggingHandle:processKeyDown(draggerTool, keyCode)
	-- Nothing to do
end

function DraggingHandle:_endHandleDrag(draggerTool)
	-- Commit the results of using the tool
	draggerTool.props.ToolImplementation:mouseUp(SelectionHelper.getMouseRay())
	draggerTool:_updateSelectionInfo() -- Since the seleciton has been edited by Implementation

	for _, part in ipairs(self._draggingModifiedParts) do
		part.LocalTransparencyModifier = 0
	end

	draggerTool._boundsChangedTracker:install()

	local cframe, offset = draggerTool._derivedWorldState:getBoundingBox()
	setInsertPoint(cframe * offset)

	draggerTool:_analyticsSendHandleDragged()
end

return DraggingHandle