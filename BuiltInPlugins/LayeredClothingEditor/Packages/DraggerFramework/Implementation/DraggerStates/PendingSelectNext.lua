--[[
	When clicking on the selection in a way that doesn't change the selection on
	mouse down, attempt to select the next selectables instead when the mouse is
	released. The reason that we do this on mouse up is for uniformity with the
	begin freeform drag behavior.
]]
local DraggerFramework = script.Parent.Parent.Parent

local DraggerStateType = require(DraggerFramework.Implementation.DraggerStateType)
local StandardCursor = require(DraggerFramework.Utility.StandardCursor)

local PendingSelectNext = {}
PendingSelectNext.__index = PendingSelectNext

function PendingSelectNext.new(draggerToolModel, isDoubleClick, dragInfo)
	local self = setmetatable({
		_draggerToolModel = draggerToolModel,
		_dragInfo = dragInfo,
		_initialMouseLocation = draggerToolModel._draggerContext:getMouseLocation(),
		_wasDoubleClick = isDoubleClick,
	}, PendingSelectNext)
	return self
end

function PendingSelectNext:enter()
end

function PendingSelectNext:leave()
end

function PendingSelectNext:render()
	self._draggerToolModel:setMouseCursor(StandardCursor.getOpenHand())
end

function PendingSelectNext:processSelectionChanged()
	self:_transitionBack()
end

function PendingSelectNext:processMouseDown()
end

function PendingSelectNext:processViewChanged()
end

function PendingSelectNext:processMouseUp()
	if self._initialMouseLocation == self._draggerToolModel._draggerContext:getMouseLocation() then
		-- Clicked nothing without moving
		self._draggerToolModel:selectNextSelectables(self._dragInfo, self._wasDoubleClick)
	end
	self:_transitionBack()
end

function PendingSelectNext:processKeyDown(keyCode)
end

function PendingSelectNext:processKeyUp(keyCode)
end

function PendingSelectNext:_transitionBack()
	self._draggerToolModel:transitionToState(DraggerStateType.Ready)
end

return PendingSelectNext