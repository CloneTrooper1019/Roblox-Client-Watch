--[[
	DraggerContext is a class which wraps all of the global state which the
	dragger needs to access to operate. This is the fixture implementation of
	the context, which allows the values which the globals will have to be
	expicitly set, to be used in doing testing.
]]

local StudioService = game:GetService("StudioService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local DraggerFramework = script.Parent.Parent

local Colors = require(DraggerFramework.Utility.Colors)

local MockAnalytics = require(DraggerFramework.Utility.MockAnalytics)

local DraggerContext = {}
DraggerContext.__index = DraggerContext

local RAYCAST_DIRECTION_SCALE = 10000

local VIEWPORT_SIZE = 1000

local MAX_UNDO_WAYPOINTS = 20

function DraggerContext.new(guiTarget, selection)
	assert(selection ~= nil)
	return setmetatable({
		_guiTarget = guiTarget,
		_useLocalSpace = false,
		_areCollisionsEnabled = true,
		_areConstraintsEnabled = false,
		_areConstraintDetailsShown = false,
		_drawConstraintsOnTop = false,
		_shouldJoinSurfaces = true,
		_mouseLocation = Vector2.new(),
		_mouseUnitRay = Ray.new(Vector3.new(), Vector3.new()),
		_cameraCFrame = CFrame.new(),
		_cameraSize = 10,
		_mouseIcon = "",
		_isSimulating = false,
		_gridSize = 1,
		_rotateIncrement = math.rad(30),
		_selection = selection,
		_undoWaypoints = {},
		_isAltDown = false,
		_isCtrlDown = false,
		_isShiftDown = false,
		_settingValues = {},
	}, DraggerContext)
end

-- What instance should the plugin's GUI objects get created under?
function DraggerContext:getGuiParent()
	return self._guiTarget
end

function DraggerContext:setHoverInstance(instance)
	self._hoverInstance = instance
end

function DraggerContext:expectHoverInstance(instance)
	if self._hoverInstance ~= instance then
		local expected = instance and instance:GetFullName() or "nil"
		local got = self._hoverInstance and self._hoverInstance:GetFullName() or "nil"
		error("Wrong hover instance,\n    Expected: " .. expected .. "\n    Got: " .. got)
	end
end

function DraggerContext:shouldUseLocalSpace()
	return self._useLocalSpace
end

function DraggerContext:setUseLocalSpace(value)
	self._useLocalSpace = value
end

function DraggerContext:areCollisionsEnabled()
	return self._areCollisionsEnabled
end

function DraggerContext:setCollisionsEnabled(value)
	self._areCollisionsEnabled = value
end

function DraggerContext:areConstraintsEnabled()
	return self._areConstraintsEnabled
end

function DraggerContext:setConstraintsEnabled(value)
	self._areConstraintsEnabled = value
end

function DraggerContext:areConstraintDetailsShown()
	return self._areConstraintDetailsShown
end

function DraggerContext:setConstraintDetailsShown(value)
	self._areConstraintDetailsShown = value
end

function DraggerContext:shouldDrawConstraintsOnTop()
	return self._drawConstraintsOnTop
end

function DraggerContext:setDrawConstraintsOnTop(value)
	self._drawConstraintsOnTop = value
end

function DraggerContext:shouldJoinSurfaces()
	return self._shouldJoinSurfaces
end

function DraggerContext:setJoinSurfaces(value)
	assert(typeof(value) == "boolean") -- Don't try to pass the Enum
	self._shouldJoinSurfaces = value
end

function DraggerContext:shouldShowHover()
	return true
end

function DraggerContext:shouldAnimateHover()
	return true
end

function DraggerContext:shouldSelectScopeByDefault()
	return true
end

function DraggerContext:getHoverAnimationSpeedInSeconds()
	return 0.5
end

function DraggerContext:getHoverBoxColor(isActive)
	return Color3.new()
end

function DraggerContext:getHoverLineThickness()
	return 0.04
end

function DraggerContext:getSelectionBoxColor(isActive)
	return Color3.new()
end

function DraggerContext:getGeometrySnapColor()
	return Color3.new()
end

function DraggerContext:getCameraCFrame()
	return self._cameraCFrame
end

function DraggerContext:setCamera(cframe, size)
	self._cameraCFrame = cframe
	self._cameraSize = size or 10
end

function DraggerContext:getHandleScale(focusPoint)
	return 1.0
end

function DraggerContext:getMouseUnitRay()
	return self:viewportPointToRay(self._mouseLocation)
end

function DraggerContext:getMouseRay()
	local unitRay = self:getMouseUnitRay()
	return Ray.new(unitRay.Origin, unitRay.Direction * RAYCAST_DIRECTION_SCALE)
end

function DraggerContext:getMouseLocation()
	return self._mouseLocation
end

function DraggerContext:setMouseLocation(location)
	self._mouseLocation = location
end

function DraggerContext:viewportPointToRay(screenPoint)
	local x = (screenPoint.X / VIEWPORT_SIZE - 0.5) * self._cameraSize
	local y = (screenPoint.Y / VIEWPORT_SIZE - 0.5) * self._cameraSize
	local at = self._cameraCFrame:PointToWorldSpace(Vector3.new(x, y, 0))
	return Ray.new(at, self._cameraCFrame.LookVector)
end

function DraggerContext:worldToViewportPoint(worldPoint)
	local point = self._cameraCFrame:Inverse() * worldPoint
	local x = (point.X / self._cameraSize + 0.5) * VIEWPORT_SIZE
	local y = (point.Y / self._cameraSize + 0.5) * VIEWPORT_SIZE
	local onScreen =
		(x >= 0 and x <= VIEWPORT_SIZE) and
		(y >= 0 and y <= VIEWPORT_SIZE) and
		point.Z < 0
	return Vector2.new(x, y), onScreen
end

function DraggerContext:getViewportSize()
	return Vector2.new(VIEWPORT_SIZE, VIEWPORT_SIZE)
end

function DraggerContext:setMouseIcon(icon)
	self._mouseIcon = icon
end

function DraggerContext:expectMouseIcon(icon)
	if self._mouseIcon ~= icon then
		local expected = icon or "nil"
		local got = self._mouseIcon or "nil"
		error("Wrong mouse icon,\n    Expected: " .. expected .. "\n    Got: " .. got)
	end
end

function DraggerContext:getSelection()
	return self._selection
end

-- Are non-anchored parts in the world currently being physically simulated?
-- (i.e. are they moving around of thier own accord)
function DraggerContext:isSimulating()
	return self._isSimulating
end

function DraggerContext:setSimulating(value)
	self._isSimulating = value
end

function DraggerContext:isAltKeyDown()
	return self._isAltDown
end

function DraggerContext:isCtrlKeyDown()
	return self._isCtrlDown
end

function DraggerContext:isShiftKeyDown()
	return self._isShiftDown
end

function DraggerContext:shouldExtendSelection()
	return self:isCtrlKeyDown() or self:isShiftKeyDown()
end

function DraggerContext:setCtrlAltShift(ctrl, alt, shift)
	self._isCtrlDown = ctrl
	self._isAltDown = alt
	self._isShiftDown = shift
end

function DraggerContext:getGridSize()
	return self._gridSize
end

function DraggerContext:snapToGridSize(distance)
	-- Use an exact check here because we're in control of things, we can set
	-- exactly grid size = 0 when snapping should be disabled.
	if self._gridSize > 0 then
		return math.floor(distance / self._gridSize + 0.5) * self._gridSize
	else
		return distance
	end
end

function DraggerContext:getRotateIncrement()
	return self._rotateIncrement
end

function DraggerContext:setGridSize(value)
	self._gridSize = math.max(value, 0.001)
end

function DraggerContext:setRotateIncrement(value)
	self._rotateIncrement = value
end

function DraggerContext:getAnalytics()
	return MockAnalytics
end

function DraggerContext:gizmoRaycast(origin, direction, raycastParams)
	return StudioService:GizmoRaycast(origin, direction, raycastParams)
end

function DraggerContext:setInsertPoint(location)
	self._insertPoint = location
end

function DraggerContext:expectInsertPoint(location)
	if self._insertPoint ~= location then
		local expected = tostring(location)
		local got = tostring(self._insertPoint)
		error("Wrong insert point,\n    Expected: " .. expected .. "\n    Got: " .. got)
	end
end

function DraggerContext:shouldShowActiveInstanceHighlight()
	return true
end

function DraggerContext:shouldAlignDraggedObjects()
	return true
end

function DraggerContext:addUndoWaypoint(waypointIdentifier, waypointText)
	if ChangeHistoryService then
		ChangeHistoryService:SetWaypoint(waypointIdentifier)
	end
	table.insert(self._undoWaypoints, waypointIdentifier)
	while #self._undoWaypoints > MAX_UNDO_WAYPOINTS do
		table.remove(self._undoWaypoints, 1)
	end
end

function DraggerContext:expectMostRecentUndoWaypoint(waypointIdentifier)
	local mostRecent = self._undoWaypoints[#self._undoWaypoints]
	if mostRecent ~= waypointIdentifier then
		error("Wrong last undo waypoint,\n    Expected: " .. waypointIdentifier ..
			"\n    Got: " .. (mostRecent or "<none>"))
	end
end

function DraggerContext:expectAndUndo(waypointIdentifier)
	self:expectMostRecentUndoWaypoint(waypointIdentifier)
	self._undoWaypoints[#self._undoWaypoints] = nil
	if ChangeHistoryService then
		ChangeHistoryService:Undo()
	end
end

function DraggerContext:getText(scope, key, args)
	if args then
		return ("%s.%s (%s)").format(scope, key, table.concat(args, ","))
	else
		return ("%s.%s").format(scope, key)
	end
end

function DraggerContext:getThemeColor(item)
	if item == Enum.StudioStyleGuideColor.MainBackground then
		return Colors.WHITE
	else
		return Colors.BLACK
	end
end

function DraggerContext:getSetting(name)
	return self._settingValues[name]
end

function DraggerContext:setSetting(name, value)
	self._settingValues[name] = value
end

function DraggerContext:setPivotIndicator(state)
	return false
end

return DraggerContext
