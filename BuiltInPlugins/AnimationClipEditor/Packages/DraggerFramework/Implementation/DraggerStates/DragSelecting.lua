local DraggerFramework = script.Parent.Parent.Parent
local Packages = DraggerFramework.Parent

local Roact = require(Packages.Roact)
local DragSelectionView = require(DraggerFramework.Components.DragSelectionView)
local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local DragSelector = require(DraggerFramework.Utility.DragSelector)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local DragSelecting = {}
DragSelecting.__index = DragSelecting

function DragSelecting.new(draggerToolModel)
	local self = setmetatable({
		_dragSelector = DragSelector.new(
			draggerToolModel:getSelectionWrapper(),
			draggerToolModel:getSchema().beginBoxSelect,
			draggerToolModel:getSchema().endBoxSelect),
		_draggerToolModel = draggerToolModel,
	}, DragSelecting)
	self:_init()
	return self
end

function DragSelecting:enter()
	self._mouseStartLocation =
		self._draggerToolModel._draggerContext:getMouseLocation()
end

function DragSelecting:leave()

end

function DragSelecting:_init()
	self._draggerToolModel._sessionAnalytics.dragSelects = self._draggerToolModel._sessionAnalytics.dragSelects + 1
	self._hasMovedMouse = false
end

function DragSelecting:render()
	self._draggerToolModel:setMouseCursor(StandardCursor.getArrow())

	local startLocation =
		self._hasMovedMouse and
		self._dragSelector:getStartLocation() or
		self._draggerToolModel._draggerContext:getMouseLocation()
	return Roact.createElement(DragSelectionView, {
		DragStartLocation = startLocation,
		DragEndLocation = self._draggerToolModel._draggerContext:getMouseLocation(),
	})
end

function DragSelecting:processSelectionChanged()
	-- Don't do anything. We don't want to unnecessarily fight other sources
	-- over selection changes.
end

function DragSelecting:processMouseDown()
	error("Mouse should already be down while drag selecting.")
end

function DragSelecting:processViewChanged()
	if not self._hasMovedMouse then
		self._dragSelector:beginDrag(
			self._draggerToolModel._draggerContext, self._mouseStartLocation)
		self._hasMovedMouse = true
	end
	self._dragSelector:updateDrag(self._draggerToolModel._draggerContext)
end

function DragSelecting:processMouseUp()
	if self._hasMovedMouse then
		self._dragSelector:commitDrag(self._draggerToolModel._draggerContext)
		self._draggerToolModel:_updateSelectionInfo()
		self._hasMovedMouse = false
	end
	self._draggerToolModel:_analyticsSendBoxSelect()
	self._draggerToolModel:transitionToState(DraggerStateType.Ready)
end

function DragSelecting:processKeyDown(keyCode)
	-- Nothing to do
end

function DragSelecting:processKeyUp(keyCode)
	-- Nothing to do.
end

return DragSelecting