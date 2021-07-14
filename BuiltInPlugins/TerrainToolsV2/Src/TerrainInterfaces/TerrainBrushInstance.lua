game:DefineFastFlag("TerrainToolsBrushUseIsKeyDown", false)

local FFlagTerrainToolsPartInteractToggle = game:GetFastFlag("TerrainToolsPartInteractToggle")
local FFlagTerrainToolsBrushUseIsKeyDown = game:GetFastFlag("TerrainToolsBrushUseIsKeyDown")

local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Cryo = require(Plugin.Packages.Cryo)

local FrameworkUtil = Framework.Util
local Signal = FrameworkUtil.Signal

local Constants = require(Plugin.Src.Util.Constants)
local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local BrushShape = TerrainEnums.BrushShape
local FlattenMode = TerrainEnums.FlattenMode
local PivotType = TerrainEnums.PivotType
local ToolId = TerrainEnums.ToolId

local quickWait = require(Plugin.Src.Util.quickWait)

local TerrainBrushCursor = require(Plugin.Src.TerrainWorldUI.TerrainBrushCursor)
local TerrainBrushCursorGrid = require(Plugin.Src.TerrainWorldUI.TerrainBrushCursorGrid)

local performTerrainBrushOperation = require(Plugin.Src.TerrainOperations.performTerrainBrushOperation)

local createToolAnalytics = require(Plugin.Src.Util.createToolAnalytics)

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CLICK_THRESHOLD = 0.1

--[[
Returns:
	Vector3? point of intersection
	number? distance from linePoint to plane. Can be negative or nil.
]]
local function lineToPlaneIntersection(linePoint, lineDirection, planePoint, planeNormal)
	local denominator = lineDirection:Dot(planeNormal)
	if denominator == 0 then
		return nil, nil
	end
	local distance = (planePoint - linePoint):Dot(planeNormal) / denominator
	return linePoint + lineDirection * distance, distance
end

local function round(n)
	return math.floor(n + 0.5)
end

local function snapToVoxelGrid(vector, radius)
	local snapOffset = Vector3.new(1, 1, 1) * (radius % Constants.VOXEL_RESOLUTION)
	local tempVector = ((vector - snapOffset) / Constants.VOXEL_RESOLUTION) + Vector3.new(0.5, 0.5, 0.5)
	return (Vector3.new(math.floor(tempVector.x),
		math.floor(tempVector.y),
		math.floor(tempVector.z)) * Constants.VOXEL_RESOLUTION) + snapOffset
end

local function getCameraLookSnappedForPlane()
	local camera = Workspace.CurrentCamera
	local lookVector = camera.CoordinateFrame.lookVector
	return Vector3.new(round(lookVector.x), round(lookVector.y), round(lookVector.z)).Unit
end

local function isShiftKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function isCtrlKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
end

local function isAltKeyDown()
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
end

local function applyOverrideToSettings(settings)
	local tool = settings.currentTool

	local planeLock
	local autoMaterial

	if tool == ToolId.Flatten then
		planeLock = false
		autoMaterial = true
	end

	return Cryo.Dictionary.join(settings, {
		autoMaterial = autoMaterial,
		planeLock = planeLock,
	})
end

local TerrainBrush = {}
TerrainBrush.__index = TerrainBrush

function TerrainBrush.new(options)
	assert(options and type(options) == "table", "TerrainBrush requires an options table")

	local self = setmetatable({
		_terrain = options.terrain,
		_mouse = options.mouse,
		_analytics = options.analytics,

		_operationSettings = {
			currentTool = options.tool,
			brushShape = BrushShape.Sphere,

			cursorSize = Constants.INITIAL_BRUSH_SIZE,
			cursorHeight = Constants.INITIAL_BRUSH_SIZE,
			strength = Constants.INITIAL_BRUSH_STRENGTH,

			material = Enum.Material.Grass,
			autoMaterial = false,

			flattenMode = FlattenMode.Both,
			pivot = PivotType.Center,

			ignoreWater = true,
			ignoreParts = true,
			planeLock = false,
			fixedPlane = false,
			snapToGrid = false,
			heightPicker = false,

			planePositionY = Constants.INITIAL_PLANE_POSITION_Y,

			-- Where to perform the operation
			-- This can tween from one location to another as the user moves their mouse
			centerPoint = Vector3.new(0, 0, 0),
			-- Where the brush center is after plane lock, snap to grid, etc.
			targetPoint = Vector3.new(0, 0, 0),
			-- A point on the plane that the brush is using
			-- Note: brush might not always be using a plane, depends on plane lock, fixed plane and height picker settings
			planePoint = Vector3.new(0, 0, 0),
			-- The normal of the plane the brush is using
			planeNormal = Vector3.new(0, 1, 0),
		},

		_isRunning = false,
		_currentLoopTag = nil,

		_mouseDown = false,
		_mouseClick = false,
		_downKeys = not FFlagTerrainToolsBrushUseIsKeyDown and {} or nil,
		_connections = {},

		_cursor = TerrainBrushCursor.new(options.terrain),
		_cursorGrid = TerrainBrushCursorGrid.new(),

		_planePositionYChanged = Signal.new(),
		_heightPickerSet = Signal.new(),
		_requestBrushSizeChanged = Signal.new(),
		_requestBrushStrengthChanged = Signal.new(),
		_materialSelectRequested = Signal.new(),

		_isTerrainDirty = false,
	}, TerrainBrush)

	assert(self._terrain, "TerrainBrush needs a terrain instance")
	assert(self._mouse, "TerrainBrush needs a mouse instance")

	assert(self._operationSettings.currentTool ~= nil and self._operationSettings.currentTool ~= ToolId.None,
		"TerrainBrush needs a tool passed to constructor")

	self._raycastParams = RaycastParams.new()
	if (not FFlagTerrainToolsPartInteractToggle) then
		self._raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	end

	return self
end

function TerrainBrush:destroy()
	self:stop()
end

function TerrainBrush:subscribeToPlanePositionYChanged(...)
	return self._planePositionYChanged:Connect(...)
end

function TerrainBrush:subscribeToHeightPickerSet(...)
	return self._heightPickerSet:Connect(...)
end

function TerrainBrush:subscribeToRequestBrushSizeChanged(...)
	return self._requestBrushSizeChanged:Connect(...)
end

function TerrainBrush:subscribeToRequestBrushStrengthChanged(...)
	return self._requestBrushStrengthChanged:Connect(...)
end

function TerrainBrush:subscribeToMaterialSelectRequested(...)
	return self._materialSelectRequested:Connect(...)
end

function TerrainBrush:updateSettings(newSettings)
	assert(newSettings.currentTool == nil, "Unable to change terrain brush tool")
	newSettings.currentTool = nil
	local settings = Cryo.Dictionary.join(self._operationSettings, newSettings)
	settings = applyOverrideToSettings(settings)
	self._operationSettings = settings
	self:_updateCursor()
end

function TerrainBrush:start()
	if self._isRunning then
		return
	end
	self._isRunning = true
	self:_connectInput()
	self:_run()
end

function TerrainBrush:stop()
	self:_saveChanges()
	if not self._isRunning then
		return
	end
	self._currentLoopTag = nil

	self._mouseDown = false
	self._mouseClick = false
	if not FFlagTerrainToolsBrushUseIsKeyDown then
		self._downKeys = {}
	end
	self:_disconnectAllConnections()

	self:_destroyCursor()

	self._isRunning = false
end

function TerrainBrush:_updateCursor()
	if TerrainBrushCursor.isVisibleForOperation(self._operationSettings) then
		self._cursor:maybeCreate()
		self._cursor:update({
			size = self._operationSettings.cursorSize,
			height = self._operationSettings.cursorHeight,
			strength = self._operationSettings.strength,
			location = self._operationSettings.targetPoint,
			shape = self._operationSettings.brushShape,
			pivot = self._operationSettings.pivot,
			mouseDown = self._mouseDown,
		})
	else
		self._cursor:hide()
	end

	if TerrainBrushCursorGrid.isVisibleForOperation(self._operationSettings) then
		self._cursorGrid:maybeCreate()
		self._cursorGrid:update({
			cursorSize = self._operationSettings.cursorSize,
			planePoint = self._operationSettings.planePoint,
			planeNormal = self._operationSettings.planeNormal,
			mouseDown = self._mouseDown,
		})
	else
		self._cursorGrid:hide()
	end
end

function TerrainBrush:_destroyCursor()
	self._cursor:destroy()
	self._cursorGrid:destroy()
end

function TerrainBrush:_disconnectAllConnections()
	for _, connection in pairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
end

function TerrainBrush:_saveChanges()
	if self._isTerrainDirty then
		ChangeHistoryService:SetWaypoint("Terrain " .. self._operationSettings.currentTool)
		self._isTerrainDirty = false
	end
end

function TerrainBrush:_connectInput()
	local function connectHelper(event, func)
		if self._connections[event] then
			self._connections[event]:Disconnect()
		end

		self._connections[event] = event:Connect(func)
	end

	connectHelper(UserInputService.InputBegan, function(event, soaked)
		if not FFlagTerrainToolsBrushUseIsKeyDown then
			self._downKeys[event.KeyCode] = true
		end

		if event.UserInputType == Enum.UserInputType.MouseButton1 and not soaked and self._isRunning then
			self._mouseDown = true
			self._mouseClick = true
		end
	end)

	connectHelper(UserInputService.InputEnded, function(event, soaked)
		if not FFlagTerrainToolsBrushUseIsKeyDown then
			self._downKeys[event.KeyCode] = nil
		end

		if event.UserInputType == Enum.UserInputType.MouseButton1 and self._mouseDown then
			self._mouseDown = false
			self:_saveChanges()
		end
	end)

	if not FFlagTerrainToolsBrushUseIsKeyDown then
		connectHelper(UserInputService.WindowFocusReleased, function()
			self._downKeys = {}
		end)
	end

	local function handleScrollWheel(direction)
		local shiftDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			shiftDown = isShiftKeyDown()
		else
			shiftDown = self._downKeys[Enum.KeyCode.LeftShift] or self._downKeys[Enum.KeyCode.RightShift]
		end
		if shiftDown then
			local scalingChange = direction / 10

			local sizeGrow = self._operationSettings.cursorSize * scalingChange
			local heightGrow = self._operationSettings.cursorHeight * scalingChange

			-- If the amount we grow by is less than 1, then it's possible we'll get stuck at a position
			-- e.g. If cursorSize = 2, sizeGrow = 0.2, round(cursorSize + sizeGrow) = 2, and we're stuck there forever
			-- But if we clamp it to be bigger than 1, then round(cursorSize + sizeGrow) = 3
			if math.abs(sizeGrow) < 1 then
				sizeGrow = math.sign(sizeGrow)
			end

			if math.abs(heightGrow) < 1 then
				heightGrow = math.sign(heightGrow)
			end

			local newSize = round(self._operationSettings.cursorSize + sizeGrow)
			local newHeight = round(self._operationSettings.cursorHeight + heightGrow)

			local newSizeClamped = math.max(Constants.MIN_BRUSH_SIZE, math.min(Constants.MAX_BRUSH_SIZE, newSize))
			local newHeightClamped = math.max(Constants.MIN_BRUSH_SIZE, math.min(Constants.MAX_BRUSH_SIZE, newHeight))

			self._requestBrushSizeChanged:Fire(newSizeClamped, newHeightClamped)
		end

		local ctrlDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			ctrlDown = isCtrlKeyDown()
		else
			ctrlDown = self._downKeys[Enum.KeyCode.LeftControl] or self._downKeys[Enum.KeyCode.RightControl]
		end
		if ctrlDown then
			local newStrength = math.max(0.1, math.min(1, self._operationSettings.strength + (direction * 0.1)))

			self._requestBrushStrengthChanged:Fire(newStrength)
		end
	end

	connectHelper(self._mouse.WheelForward, function()
		handleScrollWheel(1)
	end)

	connectHelper(self._mouse.WheelBackward, function()
		handleScrollWheel(-1)
	end)
end

function TerrainBrush:putPlanePositionYIntoVector(v)
	local y = self._operationSettings.planePositionY or 0
	return Vector3.new(v.x, y, v.z)
end

function TerrainBrush:_run()
	self._isRunning = true

	-- TODO: Remove lastCursorDistance when removing FFlagTerrainToolsFixBrushNearCamera
	local lastCursorDistance = 300
	local lastPlanePoint = Vector3.new(0, 0, 0)
	local lastNormal = Vector3.new(0, 1, 0)
	local lastMainPoint = Vector3.new(0, 0, 0)
	local firstOperation = tick()

	local reportClick = true

	local loopTag = {}
	self._currentLoopTag = loopTag

	while self._currentLoopTag and self._currentLoopTag == loopTag do
		if not self._mouse then
			warn("No mouse in TerrainBrush:_run()")
			break
		end

		local currentTool = self._operationSettings.currentTool
		local heightPicker = self._operationSettings.heightPicker
		local planeLock = self._operationSettings.planeLock
		local fixedPlane = self._operationSettings.fixedPlane
		local snapToGrid = self._operationSettings.snapToGrid
		local ignoreWater = self._operationSettings.ignoreWater
		local ignoreParts = FFlagTerrainToolsPartInteractToggle and self._operationSettings.ignoreParts or nil

		local currentTick = tick()
		local radius = self._operationSettings.cursorSize * 0.5 * Constants.VOXEL_RESOLUTION

		-- Why is mouse used for camera?
		local cameraPos = self._mouse.Origin.p
		if FFlagTerrainToolsPartInteractToggle then
			if ignoreParts then
				local acceptList = {self._terrain}
				if Workspace:FindFirstChild("Baseplate") then
					table.insert(acceptList, Workspace:FindFirstChild("Baseplate"))
				end
				self._raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
				self._raycastParams.FilterDescendantsInstances = acceptList
			else
				local ignoreList = {self._cursor:getCursorPart()}
				if Players.LocalPlayer and Players.LocalPlayer.Character then
					table.insert(ignoreList, Players.LocalPlayer.Character)
				end
				self._raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
				self._raycastParams.FilterDescendantsInstances = ignoreList
			end
		else
			local acceptList = {self._terrain}
			if Workspace:FindFirstChild("Baseplate") then
				table.insert(acceptList, Workspace:FindFirstChild("Baseplate"))
			end
			self._raycastParams.FilterDescendantsInstances = acceptList
		end

		local unitRay = self._mouse.UnitRay.Direction
		local rayHit, mainPoint, hitMaterial, hitNormal

		self._raycastParams.IgnoreWater = ignoreWater

		local raycastResult = Workspace:Raycast(cameraPos, unitRay * 10000, self._raycastParams)

		if raycastResult then
			rayHit = raycastResult.Instance
			mainPoint = raycastResult.Position
			hitMaterial = raycastResult.Material
			hitNormal = raycastResult.Normal
		else
			rayHit, hitMaterial = nil, nil
			hitNormal = getCameraLookSnappedForPlane()

			local hit, distance = lineToPlaneIntersection(cameraPos, unitRay, Vector3.new(0, 0, 0), Vector3.new(0, 1, 0))
			-- Set the default Y axis for brush to be intersection of the ray and XZplane with Y = 0

			-- Check we hit the plane, and that it's in front of us
			if hit and distance and distance >= 0 then
				mainPoint = hit
			else
				mainPoint = cameraPos + unitRay * 10000
			end
		end

		if currentTool == ToolId.Add then
			mainPoint = mainPoint - unitRay * 0.05
		elseif currentTool == ToolId.Subtract or currentTool == ToolId.Paint or currentTool == ToolId.Grow then
			mainPoint = mainPoint + unitRay * 0.05
		end

		if heightPicker or (currentTool == ToolId.Flatten and self._mouseClick and not fixedPlane and not planeLock) then
			self._planePositionYChanged:Fire(snapToGrid and snapToVoxelGrid(mainPoint, radius).y or (mainPoint.y - 1))
		end

		local shiftDown
		if FFlagTerrainToolsBrushUseIsKeyDown then
			shiftDown = isShiftKeyDown()
		else
			shiftDown = self._downKeys[Enum.KeyCode.LeftShift] or self._downKeys[Enum.KeyCode.RightShift]
		end

		local usePlanePositionY = fixedPlane and not heightPicker and self._operationSettings.planePositionY ~= nil

		local updatePlane = true
		if planeLock and shiftDown then
			-- Whilst the shift key is held we don't want to update the plane
			-- Acts like a temporary fixed plane
			updatePlane = false

		elseif self._mouseDown and not self._mouseClick then
			updatePlane = false
		end

		if updatePlane then
			lastPlanePoint = usePlanePositionY and self:putPlanePositionYIntoVector(mainPoint)
				or mainPoint
			if currentTool ~= ToolId.Flatten and not planeLock then
				lastNormal = hitNormal
			else
				lastNormal = currentTool == ToolId.Flatten and Vector3.new(0, 1, 0)
					or getCameraLookSnappedForPlane()
			end
			reportClick = true
		end

		local mainPointOnPlane = lineToPlaneIntersection(cameraPos, unitRay, lastPlanePoint, lastNormal)
		if not mainPointOnPlane then
			-- lineToPlaneIntersection can return nil, so just fallback to camera
			mainPointOnPlane = cameraPos
		end

		if snapToGrid then
			mainPoint = snapToVoxelGrid(mainPoint, radius)
			mainPointOnPlane = snapToVoxelGrid(mainPointOnPlane, radius)
		end

		if usePlanePositionY then
			-- It's possible that the previous blocks could change the Y value of mainPointOnPlane
			-- So if we're using planePositionY, then ensure that we keep using Y = planePositionY
			mainPointOnPlane = self:putPlanePositionYIntoVector(mainPointOnPlane)
		end

		if planeLock then
			mainPoint = mainPointOnPlane
		end

		self._operationSettings.targetPoint = mainPoint
		self._operationSettings.planePoint = mainPointOnPlane
		self._operationSettings.planeNormal = lastNormal

		if self._mouseDown then
			if self._mouseClick then
				firstOperation = currentTick
				lastMainPoint = mainPoint
			end

			if self._mouseClick or currentTick > firstOperation + CLICK_THRESHOLD then
				self._mouseClick = false

				if reportClick then
					if self._analytics then
						self._analytics:report("useBrushToolExtended", createToolAnalytics(self._operationSettings))
					end
					reportClick = false
				end

				local altDown
				if FFlagTerrainToolsBrushUseIsKeyDown then
					altDown = isAltKeyDown()
				else
					altDown = self._downKeys[Enum.KeyCode.LeftAlt] or self._downKeys[Enum.KeyCode.RightAlt]
				end
				if altDown then
					if rayHit and rayHit:IsA("Terrain") then
						self._materialSelectRequested:Fire(hitMaterial, isShiftKeyDown())
					end
				else
					local difference = mainPoint - lastMainPoint
					local dragDistance = difference.magnitude
					local crawlDistance = radius * 0.5

					local shouldPerformOperation = true

					if dragDistance > crawlDistance then
						local differenceVector = difference.unit
						local dragDistance = math.min(dragDistance, (crawlDistance * 2) + 20)
						local samples = math.ceil((dragDistance / crawlDistance) - 0.1)

						if currentTool == ToolId.Add and not planeLock then
							-- calculate a cos from two unit vectors unitRay and difference.unit to check
							-- if the direction of the next BrushOperation points towards the currentCamera
							local directionCos = unitRay:Dot(difference.unit)
							if math.abs(directionCos) > 0.99 then
								shouldPerformOperation = false
							end
						end

						if shouldPerformOperation then
							for i = 1, samples, 1 do
								self._operationSettings.centerPoint = lastMainPoint + (differenceVector * dragDistance * (i / samples))
								performTerrainBrushOperation(self._terrain, self._operationSettings)
							end
							mainPoint = lastMainPoint + differenceVector * dragDistance
						end
					else
						if currentTool == ToolId.Add and not planeLock then
							-- calculate a cos from two unit vectors unitRay and difference.unit to check
							-- if the direction of the next BrushOperation points towards the currentCamera
							local directionCos = unitRay:Dot(difference.unit)
							if not ((difference - Vector3.new(0, 0, 0)).magnitude < 0.01 or math.abs(directionCos) < 0.99) then
								shouldPerformOperation = false
							end
						end

						if shouldPerformOperation then
							self._operationSettings.centerPoint = mainPoint
							performTerrainBrushOperation(self._terrain, self._operationSettings)
						end
					end

					if shouldPerformOperation then
						self._isTerrainDirty = true
						lastMainPoint = mainPoint
					end
				end
			end

			if currentTool == ToolId.Flatten and heightPicker then
				self._heightPickerSet:Fire(false)
			end
		end

		self:_updateCursor()

		quickWait()
	end
end

return TerrainBrush
