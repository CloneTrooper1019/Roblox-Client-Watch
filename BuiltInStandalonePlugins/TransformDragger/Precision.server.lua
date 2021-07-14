--!nocheck
--!nolint UnknownType

local plugin, settings = plugin, settings

local EngineFeatureModelPivotApi = game:GetEngineFeature("ModelPivotApi")
-----------------------------------
-------------FAST FLAGS------------
-----------------------------------
--local Flags =  script.Parent.Parent.Flags
local getFFlagFixTransformScalingSpheresAndCylinders =
	require(script.Parent.Flags.getFFlagFixTransformScalingSpheresAndCylinders)

-----------------------------------
-----------MODULE SCRIPTS----------
-----------------------------------

local Collision = require(script.Parent.Collision)
local Utility = require(script.Parent.Utility)
local List = require(script.Parent.List)
local Selection = require(script.Parent.Selection)
local Metapart = require(script.Parent.Metapart)
local FuzzyMath = require(script.Parent.FuzzyMath)
local Round = require(script.Parent.Round)
local Extent = require(script.Parent.Extent)
local Adorn = require(script.Parent.Adornments)
local Input = require(script.Parent.Input)
local RubberBand = require(script.Parent.Rubberband)
local Analytics = require(script.Parent.Analytics)

-----------------------------------
------NEW LUADRAGGER ANALYTICS-----
-----------------------------------
do
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local Selection = game:GetService("Selection")
	local StudioService = game:GetService("StudioService")
	local sessionAnalytics = nil
	local dragAnalytics = nil
	local ANALYTICS_NAME = "Transform"
	local selectedAtTime = 0
	local dragStartLocation = nil

	function analyticsSessionBegin()
		selectedAtTime = tick()
		sessionAnalytics = {
			freeformDrags = 0,
			handleDrags = 0,
			clickSelects = 0,
			dragSelects = 0,
			dragTilts = 0,
			dragRotates = 0,
			toolName = ANALYTICS_NAME,
			wasAutoSelected = false,
		}
		Analytics:sendEvent("toolSelected", {
			toolName = ANALYTICS_NAME,
			wasAutoSelected = false,
		})
		Analytics:reportCounter("studioLua" .. ANALYTICS_NAME .. "DraggerSelected")
	end

	function analyticsSendSession()
		local totalTime = tick() - selectedAtTime
		sessionAnalytics.duration = totalTime
		Analytics:sendEvent("toolSession", sessionAnalytics)
	end

	function analyticsSendClick(clickedInstance, didChangeSelection)
		Analytics:sendEvent("clickedObject", {
			altPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt),
			ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl),
			shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift),
			clickedAttachment = clickedInstance and clickedInstance:IsA("Attachment"),
			clickedConstraint = clickedInstance and
				(clickedInstance:IsA("Constraint") or clickedInstance:IsA("WeldConstraint")),
			didAlterSelection = didChangeSelection,
		})
		if didChangeSelection then
			sessionAnalytics.clickSelects = sessionAnalytics.clickSelects + 1
		end
	end

	function analyticsRecordFreeformDragBegin()
		local partCount = 0
		for _, selectedObject in pairs(Selection:Get()) do
			if selectedObject:IsA("BasePart") then
				partCount = partCount + 1
			end
			for _, descendant in pairs(selectedObject:GetDescendants()) do
				if descendant:IsA("BasePart") then
					partCount = partCount + 1
				end
			end
		end
		sessionAnalytics.freeformDrags = sessionAnalytics.freeformDrags + 1
		dragAnalytics = {
			dragTilts = 0,
			dragRotates = 0,
			partCount = partCount,
			attachmentCount = 0,
			timeToStartDrag = 0,
		}
		dragStartLocation = nil
	end

	function analyticsRecordFreeformDragUpdate(position)
		if dragAnalytics then
			dragAnalytics.dragTargetType = "Polygon" -- hard code this, too hard to add
			if dragStartLocation then
				dragAnalytics.dragDistance =
					(position - dragStartLocation).Magnitude
			else
				dragAnalytics.dragDistance = 0
				dragStartLocation = position
			end
			dragAnalytics.distanceToCamera =
				(Workspace.CurrentCamera.CFrame.Position - position).Magnitude
		end
	end

	function analyticsSendFreeformDragged()
		if dragAnalytics then
			-- I can't quite figure out the conditions under which a drag is
			-- in progress in the mouse-up, so using this if statement instead.
			dragAnalytics.gridSize = StudioService.GridSize
			dragAnalytics.toolName = ANALYTICS_NAME
			dragAnalytics.wasAutoSelected = false
			dragAnalytics.joinSurfaces = false
			dragAnalytics.useConstraints = false
			Analytics:sendEvent("freeformDragged", dragAnalytics)
			dragAnalytics = nil
		end
	end

	function analyticsSendHandleDragged(handleName)
		Analytics:sendEvent("handleDragged", {
			toolName = ANALYTICS_NAME,
			gridSize = StudioService.GridSize,
			rotateIncrement = StudioService.RotateIncrement,
			useLocalSpace = false,
			joinSurfaces = false,
			useConstraints = false,
			haveCollisions = false,
			wasAutoSelected = false,
		})
		Analytics:sendEvent("transformHandleDragged", {
			gridSize = StudioService.GridSize,
			rotateIncrement = StudioService.RotateIncrement,
			handleName = handleName,
		})
	end

	function analyticsSendBoxSelect()
		Analytics:sendEvent("boxSelected", {
			toolName = ANALYTICS_NAME,
			objectCount = #Selection:Get(),
			altPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt),
			ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl),
			shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift),
			wasAutoSelected = false,
		})
	end

	function analyticsSendSetPlane()
		Analytics:sendEvent("setPlane", {
			toolName = ANALYTICS_NAME,
		})
	end
end

-----------------------------------
--------------VARIABLES------------
-----------------------------------

local loaded = false
local on = false

local mouse = plugin:GetMouse(true)
Input.setMouse(mouse)

local hasStartedDragging = false

local allowYSnap = false

local initializedDragPlane = false

local adornmentUpdateNeeded = true

local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

local shouldBreakJoints = true

local currentlySelecting = false

local planeObject = nil
local holoBox = nil
local planeDragging = false

local localSpace = true

local rotateAdornPart = nil

local hoveredHandles = {n = 0}

local currentDist = nil

local originalSize = nil
local originalCFrame = nil

local lastDist = Vector3.new(0,0,0)

local originalPosition = nil;

local freeDragging = nil;

local startLocation = nil

local baseDragPlane = nil
local dragPlane = nil

local secondaryPart = nil
local secondaryLocation = nil
local secondaryPartCFrame = nil

local secondaryPartSideSelected = nil
local workplaneOffset = 0

local invisiblePart = nil
local previousAABBCFrame = nil

local selectionBoxStart = nil

local pV0, pV1, pV2 = nil
local w0, w1, w2, w3 = nil

local workplaneFrame = CFrame.new()

local currentlyOverHandle = false
local initialPos = nil

local mouseOffsetOnGrabHandle = nil

------------------------------------

local castPart = nil
local castSecondaryPart = nil
local castSecondaryLocation = nil
local castSecondaryPartSideSelected = nil
local castPartAdorn = nil
local castPlane = nil
local castWorkplaneOffset = nil

local waypointUndoConnection = nil
local waypointRedoConnection = nil
local inputBeganConnection = nil
local inputEndedConnection = nil
local inputChangedConnection = nil
local selectionChangedConnection = nil
local renderSteppedConnection = nil
local dragEnterConnection = nil

local selectedPartCFrameBeforeDrag = nil

local dragFromToolbox = false

local clickOnUpdate = false

local updateInvisiblePartNeeded = 0

local handleWasDragged = false

local dragPart
local dragPartHoloBox

local TOP_SIDE = 0
local BOTTOM_SIDE = 1
local LEFT_SIDE = 2
local RIGHT_SIDE = 3
local FRONT_SIDE = 4
local BACK_SIDE = 5

local function getWorkplane()
	return workplaneFrame, workplaneOffset
end

Adorn.setWorkplaneAccessor(getWorkplane)

--handleDeclaration
local H_NONE = 0
local T_Y_POS = 1
local S_X_POS = 2
local S_X_NEG = 3
local S_Z_POS = 4
local S_Z_NEG = 5
local S_Y_POS = 6
local S_X_POS_Z_POS = 7
local S_X_POS_Z_NEG = 8
local S_X_NEG_Z_POS = 9
local S_X_NEG_Z_NEG = 10
local R_XY = 11
local R_XZ = 12
local R_YZ = 13
local H_PLANE = 14

local HandleNames = {}
HandleNames[H_NONE] = "None"
HandleNames[T_Y_POS] = "Translate"
HandleNames[S_X_POS] = "ScaleEdge"
HandleNames[S_X_NEG] = "ScaleEdge"
HandleNames[S_Z_POS] = "ScaleEdge"
HandleNames[S_Z_NEG] = "ScaleEdge"
HandleNames[S_Y_POS] = "ScaleEdge"
HandleNames[S_X_POS_Z_POS] = "ScaleCorner"
HandleNames[S_X_POS_Z_NEG] = "ScaleCorner"
HandleNames[S_X_NEG_Z_POS] = "ScaleCorner"
HandleNames[S_X_NEG_Z_NEG] = "ScaleCorner"
HandleNames[R_XY] = "Rotate"
HandleNames[R_XZ] = "Rotate"
HandleNames[R_YZ] = "Rotate"
HandleNames[H_PLANE] = "Plane"

local handlesCurrentlyOver = {}

local setAnchoredStateForMovingParts = false
local states = {}


local function BreakJoints(part)
	if part:IsA("Wrapped") then
		workspace:UnjoinFromOutsiders({part.Object})
	elseif part:IsA("BasePart") then
		workspace:UnjoinFromOutsiders({part})
	end
end

local function JoinSelection()
	local selection = Selection.getFilteredSelection()
	workspace:JoinToOutsiders(selection, plugin:GetJoinMode())
end

local function UnjoinSelection()
	local selection = Selection.getFilteredSelection()
	workspace:UnjoinFromOutsiders(selection)
end

--duplicate code, please consolidate
local roots = {}

local function getAllRoots(item)

	if item:IsA("BasePart") and item:GetRootPart() then
		roots[item:GetRootPart()] = true
	end

	local children = item:GetChildren()
	for i, v in ipairs(children) do
		getAllRoots(v)
	end
end

local function getSelectionRoots()
	local selection = Selection.getFilteredSelection()

	roots = {}

	for i, v in ipairs(selection) do
		getAllRoots(v)
	end
	return roots
end

local function setModelCFrame(model, finalCF)
	roots = {}
	getAllRoots(model)

	local originalCF = model:GetModelCFrame()

	for k, v in pairs(roots) do
		k.CFrame = finalCF:toWorldSpace(originalCF:toObjectSpace(k.CFrame))
	end
end

local function moveSelection(initialCFrame, finalCFrame)
	local rootSelection = getSelectionRoots()

	for k, v in pairs(rootSelection) do
		k.CFrame = finalCFrame:toWorldSpace(initialCFrame:toObjectSpace(k.CFrame))
	end
end

local function updateRotatePart()

	local selection = Selection.getFilteredSelection()

	if #selection > 0 then
		if not rotateAdornPart then
			rotateAdornPart = Instance.new("Part", game.CoreGui)
			rotateAdornPart.Name = "RotateAdornPart"
		end

		local filteredSelectionMetaPart = Selection.getFilteredSelectionMetapart()
		rotateAdornPart.CFrame = filteredSelectionMetaPart.CFrame
		rotateAdornPart.Size = filteredSelectionMetaPart.Size
		Adorn.adornInstanceWithRotate(rotateAdornPart)

	end

end

local function updateAdornments()
	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
	if filteredSelectionMetapart then
		filteredSelectionMetapart.ClearCache()
	end

	updateInvisiblePart()
	updateRotatePart()
end

local function onPressMouse()

	hasStartedDragging = false

	Adorn.grabHandle()

	local currentHandle = Adorn.getCurrentHandle()

	if currentHandle == H_NONE and not Adorn.isPlaneSelectingModeOn() then selectPart() end

	if currentHandle == H_PLANE then
		initialPos = mouse.Origin.p

		analyticsSendSetPlane()
	else
		local currentAdorn = Adorn.getCurrentAdornment()
		if currentAdorn then
			initialPos = Adorn.getAdornmentWorldCFrame(Adorn.getCurrentAdornment()[1]).p
		end
	end

	grabHandle(currentHandle, initialPos)
end

local function onReleaseMouse()
	initialPos = nil

	if hasStartedDragging then
		if RubberBand.isRubberBandDragInProgress() then
			analyticsSendBoxSelect()
		else
			analyticsSendFreeformDragged()
		end
	end
	if not RubberBand.isRubberBandDragInProgress() then
		releaseHandle()
	end
	releasePart()
	Adorn.releaseHandle()

	planeDragging = false
	if planeObject and false then
		planeObject:Destroy()
		planeObject = nil
	end
end

-------------------------------------------------

plugin:OnInvoke("buttonClicked", function(payload)
	if on and Off then
		Off()
	elseif loaded and On then
		On()
	end
end)

-- plugin:Deactivate() can't be called from main.server.lua where we connect to
-- StudioService.PromptTransformPluginCheckEnable, it doesnt have the correct
-- instance of plugin. This is why we have this intermediary event "Disable" that
-- gets caught by the correct instance and then calls deactivate properly
plugin:OnInvoke("Disable", function()
	plugin:Deactivate()
end)

plugin.Deactivation:connect(function()
	if on and Off then
		Off()
	end
end)

--------------------MATH STUFFS-------------------
function squaredMagnitude(vect3)
	return vect3.X*vect3.X + vect3.Y*vect3.Y + vect3.Z*vect3.Z
end

function vector3Direction(vect3)
	local lenSquared = squaredMagnitude(vect3)
	local invSqrt = 1.0 / math.sqrt(lenSquared)
	return Vector3.new(vect3.X * invSqrt, vect3.Y * invSqrt, vect3.Z *invSqrt)
end

function vector3LessThanOrEqualTo(vect1, vect2)
	return vect1.x <= vect2.x and vect1.y <= vect2.y and vect1.z <= vect2.z
end

function vector3GreaterThanOrEqualTo(vect1, vect2)
	return vect1.x >= vect2.x and vect1.y >= vect2.y and vect1.z >= vect2.z
end

function createPlane(vector0, vector1, vector2)
	local p1 = vector1 - vector0
	local p2 = vector2 - vector0
	local cross = p1:Cross(p2)
	local _normal = vector3Direction(cross)
	local _distance = _normal:Dot(vector0)
	return {v0=vector0, v1=vector1, v2=vector2, normal=_normal, distance=_distance}
end

function rayPlaneIntersection(ray, plane)
	local dotProd = ray.Direction:Dot(plane.normal)

	local t = -((-plane.distance) + ray.Origin:Dot(plane.normal)) / dotProd

	return ray.Origin + ray.Direction * t
end


function boxSideTest(ray, normal, size, p)

	local origin = size * normal
	local t = (-((-normal:Dot(origin)) + ray.Origin:Dot(normal))) / ray.Direction:Dot(normal)
	local hit = ray.Origin + ray.Direction * t

	if (origin.x ~= 0 or hit.x <= size.x) and
	   (origin.x ~= 0 or hit.x >= -size.x) and
	   (origin.y ~= 0 or hit.y <= size.y) and
	   (origin.y ~= 0 or hit.y >= -size.y) and
	   (origin.z ~= 0 or hit.z <= size.z) and
	   (origin.z ~= 0 or hit.z >= -size.z) then
		return hit
	end

	return nil
end

function rayBoxIntersection(ray, cframe, size)
	size = size / 2
	local localRay = Ray.new(cframe:pointToObjectSpace(ray.Origin), cframe:pointToObjectSpace(ray.Direction + cframe.p).unit )
	if (localRay.Origin.x < -size.x) and (localRay.Direction.x > 0) then
		local result = boxSideTest(localRay, Vector3.new(-1, 0, 0), size)
		if result then return cframe:pointToWorldSpace(result) end

	elseif (localRay.Origin.x > size.x) and (localRay.Direction.x < 0) then
		local result = boxSideTest(localRay, Vector3.new(1, 0, 0), size, true)
		if result then return cframe:pointToWorldSpace(result) end
	end

	if (localRay.Origin.y < -size.y) and (localRay.Direction.y > 0) then
		local result = boxSideTest(localRay, Vector3.new(0, -1, 0), size)
		if result then return cframe:pointToWorldSpace(result) end

	elseif (localRay.Origin.y > size.y) and (localRay.Direction.y < 0) then
		local result = boxSideTest(localRay, Vector3.new(0, 1, 0), size)
		if result then return cframe:pointToWorldSpace(result) end

	end

	if (localRay.Origin.z < -size.z) and (localRay.Direction.z > 0) then
		local result = boxSideTest(localRay, Vector3.new(0, 0, -1), size)
		if result then return cframe:pointToWorldSpace(result) end

	elseif (localRay.Origin.z > size.z) and (localRay.Direction.z < 0) then
		local result = boxSideTest(localRay, Vector3.new(0, 0, 1), size)
		if result then return cframe:pointToWorldSpace(result) end

	end

	return cframe:pointToWorldSpace(Vector3.new(0,0,0))
end

function projectVectorToPlane(vect, planeNormal)
	return vect - (vect:Dot(planeNormal.Unit) * planeNormal.Unit)
end

--- Collision ---
local function moveUntilCollideWrapper(part, threshold, ignoreList, direction, maximum)
	if not ignoreList then ignoreList = {} end
	return Collision.moveUntilCollide(part, ignoreList, direction, threshold, maximum)
end

local function safeMoveWrapper(part, threshold, ignoreList, direction)
	Collision.SafeMove(part, ignoreList, direction)
end

local function safeMoveWhiteList(part, direction, whiteList)
	Collision.SafeMove(part, List.createIgnoreListGivenWhiteList(game.Workspace, whiteList), direction)
end

local function safeRotate(part, previousChange)
	--TODO: Actual safe rotate
	part.CFrame =  (previousChange) * part.CFrame
end

--- Get Grid ---

function getRotationalIntervalFromGrid()
	local grid = plugin.GridSize
	if FuzzyMath.fuzzyCompare(grid, 0.2) then
		return 15
	elseif FuzzyMath.fuzzyCompare(grid, 0.01) then
		return 1
	else
		return 45
	end
end

---Round Num ---

function roundToNearestGrid(value)
	local interval = plugin.GridSize
	if interval ~= 0 then
		return Round.roundToNearest(value, interval)
	end
	return value
end

function Vector3ToNearestGrid(value)
	return Vector3.new(	roundToNearestGrid(value.X), roundToNearestGrid(value.Y), roundToNearestGrid(value.Z))
end

function getScaleHandleLocalVector(handle)
	if handle == S_X_POS then
		return Vector3.new(1, 0, 0)
	elseif handle == S_X_NEG then
		return Vector3.new(-1, 0, 0)
	elseif handle == S_Z_POS then
		return Vector3.new(0, 0, 1)
	elseif handle == S_Z_NEG then
		return Vector3.new(0, 0, -1)
	elseif handle == S_Y_POS then
		return Vector3.new(0, 1, 0)
	--elseif handle == S_Y_NEG then
	--	return Vector3.new(0, -1, 0)
	elseif handle == S_X_POS_Z_POS then
		return Vector3.new(1, 0, 1)
	elseif handle == S_X_POS_Z_NEG then
		return Vector3.new(1, 0, -1)
	elseif handle == S_X_NEG_Z_POS then
		return Vector3.new(-1, 0, 1)
	elseif handle == S_X_NEG_Z_NEG then
		return Vector3.new(-1, 0, -1)
	end
	return Vector3.new(0, 0, 0)
end

function snapVector3ByHandle(value, handle)
	if handle == S_X_POS or
	   handle == S_X_NEG or
	   handle == S_X_POS_Z_POS or
	   handle == S_X_POS_Z_NEG or
	   handle == S_X_NEG_Z_POS or
	   handle == S_X_NEG_Z_NEG then
		value = Vector3.new(math.max(roundToNearestGrid(value.X), plugin.GridSize), value.Y, value.Z)
	end

	if handle == S_Z_POS or
	   handle == S_Z_NEG or
	   handle == S_X_POS_Z_POS or
	   handle == S_X_POS_Z_NEG or
	   handle == S_X_NEG_Z_POS or
	   handle == S_X_NEG_Z_NEG then
		value = Vector3.new(value.X, value.Y, math.max(roundToNearestGrid(value.Z), plugin.GridSize))
	end

	if handle == S_Y_POS or
	   handle == T_Y_POS then
		value = Vector3.new(value.X, math.max(roundToNearestGrid(value.Y), plugin.GridSize), value.Z)
	end

	return value
end

--------------------------------------------------

function getSelectedPart()
	local selectedItems = Selection.getFilteredSelection()

	if (#selectedItems < 1) then return nil end
	return selectedItems[1]
end

function getCurrentSelectionWithChildren(children, t)
	if not t then t = {} end
	if not children then children = Selection.getFilteredSelection() end

	for i,v in pairs(children) do
		if v:IsA("BasePart") then table.insert(t, v) end
		if #v:GetChildren() then
			t = getCurrentSelectionWithChildren(v:GetChildren(), t)
		end
	end

	return t
end

function setPartPosition(part, position)
	part.CFrame = part.CFrame - part.CFrame.p + position
end

function setPartRotation(part, cframe)
	part.CFrame = cframe - cframe.p + part.CFrame.p
end

------------------------------------------------

function cosineSimilarity(v1, v2)
	local value = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z)/ (math.sqrt(math.pow(v1.x,2) + math.pow(v1.y, 2) + math.pow(v1.z, 2)) * math.sqrt(math.pow(v2.x,2) + math.pow(v2.y, 2) + math.pow(v2.z, 2)))
	local radAngle = math.acos(value)

	return math.deg(radAngle)

end

function setWaypoint()

	removeDragPart()

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()

	local currentHandle = Adorn.getCurrentHandle()
	local handleType = "Unknown"
	if currentHandle == S_X_POS or
	   currentHandle == S_Y_POS or
	   currentHandle == S_Z_POS or
	   currentHandle == S_X_NEG or
	   currentHandle == S_Z_NEG or
	   currentHandle == S_X_POS_Z_POS or
	   currentHandle == S_X_NEG_Z_POS or
	   currentHandle == S_X_NEG_Z_NEG or
	   currentHandle == S_X_POS_Z_NEG then
		handleType = "Scale"
	elseif 	currentHandle == T_Y_POS then
		handleType = "Move"
	elseif currentHandle == R_XY or
		   currentHandle == R_XZ or
		   currentHandle == R_YZ then
		handleType = "Rotate"
	end



	if filteredSelectionMetapart and (filteredSelectionMetapart.CFrame ~= originalPosition or filteredSelectionMetapart.Size ~= originalSize) then
		game:GetService("ChangeHistoryService"):SetWaypoint(handleType)
	end
end

local function setSelection(newSelection)
	game:GetService("Selection"):Set(newSelection)
end

function rotateCFrame(cframe, side)
	if side == BOTTOM_SIDE then
		cframe = cframe * CFrame.Angles(math.rad(180), 0, 0)
	elseif side == RIGHT_SIDE then
		cframe = cframe * CFrame.Angles(0, 0, -math.rad(90))
	elseif side == LEFT_SIDE then
		cframe = cframe * CFrame.Angles(0, 0, math.rad(90))
	elseif side == FRONT_SIDE then
		cframe = cframe * CFrame.Angles(-math.rad(90), 0, 0)
	elseif side == BACK_SIDE then
		cframe = cframe * CFrame.Angles(math.rad(90), 0, 0)
	end

	return cframe
end

function updateInvisiblePart()
	if not invisiblePart then return end

	local selection = Selection.getFilteredSelection()

	if #selection < 1 then
		return
	end

	if #selection > 1 then
	end
	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()

	if secondaryPart then
		if filteredSelectionMetapart then
			filteredSelectionMetapart.UpdatePlaneCFrame = workplaneFrame
			invisiblePart.CFrame = filteredSelectionMetapart.PlaneAlignedCFrame
			invisiblePart.Size = filteredSelectionMetapart.PlaneAlignedSize
		else
			local tmpCFrame = secondaryPart.CFrame
			invisiblePart.CFrame = CFrame.new(invisiblePart.CFrame.p)
			Extent.setPartCFrameToExtents(invisiblePart, rotateCFrame(tmpCFrame, secondaryPartSideSelected))
		end

	else
		Extent.setPartCFrameToExtents(invisiblePart, nil)
	end

	if secondaryLocation then
		workplaneOffset = -invisiblePart.CFrame:pointToObjectSpace(secondaryLocation).y
	end

end

local function resetDragger()
	Adorn.resetDragger()
end

--[[
	Makes spheres scale uniformly on all axes, and cylinders on YZ axes
	Returns adjusted distance vector
]]
local function adjustScalingInCaseOfSpecialParts(part, dist, handle)
	-- don't try to modify distance unless we're dealing with a part
	-- also, we don't care about rotation and translation here
	if not part:IsA("Part") or handle == T_Y_POS or handle == R_YZ or handle == R_XZ or handle == R_XY then
		return dist
	end

	-- we hide all adornments except S_Y_POS when it's a sphere
	if part.Shape == Enum.PartType.Ball then
		local r = dist.Y
		return handle == S_Y_POS  and Vector3.new(r, r, r) or dist
	elseif part.Shape == Enum.PartType.Cylinder then
		if handle == S_Y_POS then
			local r = dist.Y
			return Vector3.new(0, r, r)
		else
			-- all other adornments are in the XZ plane
			local r = dist.Z
			local h = dist.X
			return Vector3.new(h, r, r)
		end
	end
	--fallback for all other cases
	return dist
end
------------------------------------------------------------------------------------------
------------------------------Adornment Drag Part Update----------------------------------
------------------------------------------------------------------------------------------

local rotationalDiff = 0

local isInsideRotate = false
local intersectionPoint = nil

--TODO:: lots of copy pasta here, please consolidate
function preUpdatePart()
	--calculateCurrentDistance
	local currentHandle = Adorn.getCurrentHandle()
	if currentHandle == H_NONE then return end
	if not initialPos then return end

	if currentHandle == H_PLANE then return end

	local currentAdornment = Adorn.getCurrentAdornment()

	local adornee = currentAdornment[1].Adornee
	if not adornee then return end

	local worldCFrame = Adorn.getAdornmentWorldCFrame(currentAdornment[1])
	local lookVector = mouse.UnitRay

	if currentHandle == T_Y_POS or currentHandle == S_Y_POS then

		local upVector = (adornee.CFrame:pointToWorldSpace(Vector3.new(0, 1, 0)) - adornee.CFrame.p).Unit
		local planeNormal = lookVector.Direction - (lookVector.Direction:Dot(upVector) * upVector)

		local dist = planeNormal:Dot(worldCFrame.p)

		local dotProd = lookVector.Direction:Dot(planeNormal)

		local t = -((-dist) + lookVector.Origin:Dot(planeNormal)) / dotProd

		local intersection = lookVector.Origin + lookVector.Direction * t

		local origin = initialPos - (upVector.Unit * 800)

		local point = Ray.new(initialPos , upVector.Unit):ClosestPoint(intersection)

		local upV = Vector3.new(0, 1, 0)

		if point == initialPos then
			point = Ray.new(initialPos , -upVector.Unit):ClosestPoint(intersection)
			upV = upV * -1
		end

		currentDist = (point - initialPos).Magnitude * upV

	elseif currentHandle == S_X_POS or currentHandle == S_X_NEG then
		local moveVector = (adornee.CFrame:pointToWorldSpace(Vector3.new(1, 0, 0)) - adornee.CFrame.p).Unit
		local planeNormal = lookVector.Direction - (lookVector.Direction:Dot(moveVector) * moveVector)

		local dist = planeNormal:Dot(worldCFrame.p)

		local dotProd = lookVector.Direction:Dot(planeNormal)

		local t = -((-dist) + lookVector.Origin:Dot(planeNormal)) / dotProd

		local intersection = lookVector.Origin + lookVector.Direction * t

		local origin = initialPos - (moveVector.Unit * 800)

		local point = Ray.new(initialPos , moveVector.Unit):ClosestPoint(intersection)

		local upV = Vector3.new(1, 0, 0)

		if point == initialPos then
			point = Ray.new(initialPos , -moveVector.Unit):ClosestPoint(intersection)
			upV = upV * -1
		end

		currentDist = (point - initialPos).Magnitude * upV

		if currentHandle == S_X_NEG then
			currentDist = currentDist * -1
		end
	elseif currentHandle == S_Z_POS or currentHandle == S_Z_NEG then
		local moveVector = (adornee.CFrame:pointToWorldSpace(Vector3.new(0, 0, 1)) - adornee.CFrame.p).Unit
		local planeNormal = lookVector.Direction - (lookVector.Direction:Dot(moveVector) * moveVector)

		local dist = planeNormal:Dot(worldCFrame.p)

		local dotProd = lookVector.Direction:Dot(planeNormal)

		local t = -((-dist) + lookVector.Origin:Dot(planeNormal)) / dotProd

		local intersection = lookVector.Origin + lookVector.Direction * t

		local origin = initialPos - (moveVector.Unit * 800)

		local point = Ray.new(initialPos , moveVector.Unit):ClosestPoint(intersection)

		local upV = Vector3.new(0, 0, 1)

		if point == initialPos then
			point = Ray.new(initialPos , -moveVector.Unit):ClosestPoint(intersection)
			upV = upV * -1
		end

		currentDist = (point - initialPos).Magnitude * upV

		if currentHandle == S_Z_NEG then
			currentDist = currentDist * -1
		end
	elseif currentHandle == S_X_POS_Z_POS or currentHandle == S_X_NEG_Z_NEG or currentHandle == S_X_POS_Z_NEG or currentHandle == S_X_NEG_Z_POS then

		local planeNormal = (adornee.CFrame:pointToWorldSpace(Vector3.new(0, 1, 0)) - adornee.CFrame.p).Unit

		local dist = planeNormal:Dot(worldCFrame.p)
		local dotProd = lookVector.Direction:Dot(planeNormal)
		local t = -((-dist) + lookVector.Origin:Dot(planeNormal)) / dotProd
		local intersection = lookVector.Origin + lookVector.Direction * t

		currentDist = originalCFrame:pointToObjectSpace(intersection + originalCFrame.p) - originalCFrame:pointToObjectSpace(initialPos + originalCFrame.p)

		if currentHandle == S_X_NEG_Z_POS or currentHandle == S_X_NEG_Z_NEG then
			currentDist = currentDist * Vector3.new(-1, 1, 1)
		end

		if currentHandle == S_X_POS_Z_NEG or currentHandle == S_X_NEG_Z_NEG then
			currentDist = currentDist * Vector3.new(1, 1, -1)
		end

	elseif currentHandle == R_XY or currentHandle == R_XZ or currentHandle == R_YZ then

		local planeNormal = (adornee.CFrame:pointToWorldSpace(Vector3.new(currentHandle == R_YZ and 1 or 0, currentHandle == R_XZ and 1 or 0, currentHandle == R_XY and 1 or 0)) - adornee.CFrame.p).Unit

		local dist = planeNormal:Dot(worldCFrame.p)
		local dotProd = lookVector.Direction:Dot(planeNormal)
		local t = -((-dist) + lookVector.Origin:Dot(planeNormal)) / dotProd

		intersectionPoint = lookVector.Origin + lookVector.Direction * t

		currentDist = originalCFrame:pointToObjectSpace(intersectionPoint + originalCFrame.p) - originalCFrame:pointToObjectSpace(initialPos + originalCFrame.p)

		isInsideRotate = false
	end

	if not mouseOffsetOnGrabHandle then
		mouseOffsetOnGrabHandle = currentDist
	else
		currentDist = currentDist - mouseOffsetOnGrabHandle
	end
end

local planePreviouslySelected = false
local itemToUpdate = nil

local sanitizationPrecision = 1000000

local function sanitizeFloatTest(value)
	return value > 0.0 and (math.ceil((value * sanitizationPrecision) - 0.5) / sanitizationPrecision) or (math.floor((value * sanitizationPrecision) + 0.5) / sanitizationPrecision)
end

local function sanitizeCFrameTest(value)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = value:components()
	return CFrame.new(
		sanitizeFloat(x),
		sanitizeFloat(y),
		sanitizeFloat(z),
		sanitizeFloat(r00),
		sanitizeFloat(r01),
		sanitizeFloat(r02),
		sanitizeFloat(r10),
		sanitizeFloat(r11),
		sanitizeFloat(r12),
		sanitizeFloat(r20),
		sanitizeFloat(r21),
		sanitizeFloat(r22))
end

function getShapeRenderSize(shape, size)
	if (shape == Enum.PartType.Cylinder) then
		local minYZ = math.min(size.Y, size.Z)
		return Vector3.new(size.X, minYZ, minYZ)
	end

	return size
end

function updatePivotAndChildAttachments(part, initialSize, finalSize)
	if (not part:IsA("BasePart")) then return end

	local children = part:GetChildren()

	local shape = part.Shape

	initialSize = getShapeRenderSize(shape, initialSize)
	finalSize = getShapeRenderSize(shape, finalSize)

	for i = 1, #children do
		local child = children[i]
		if (child:IsA("Attachment")) then
			child.Position = (child.Position / initialSize) * finalSize
		end
	end
	
	if EngineFeatureModelPivotApi then
		part:UpdatePivot(initialSize, finalSize)
	end
end

function updatePart()

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
	local filteredSelection = Selection.getFilteredSelection()

	local currentHandle = Adorn.getCurrentHandle()
	if currentHandle == H_NONE then return end

	if not setAnchoredStateForMovingParts then
		local selection = getCurrentSelectionWithChildren()
		setAnchoredStateForMovingParts = true
		for i, v in ipairs(selection) do
			states[i] = v.Anchored
			v.Anchored = true
		end
	end

	preUpdatePart()

	if ((not originalSize or not originalCFrame) and currentHandle ~= T_Y_POS or not currentDist) then

		if currentHandle ~= R_XY and
			currentHandle ~= R_XZ and
			currentHandle ~= R_YZ and
			currentHandle ~= H_PLANE then
			return
		end
	end

	local allowAdornUpdate = true

	if selectedPart and shouldBreakJoints then
		UnjoinSelection()
		--BreakJoints(selectedPart)
	end

	local refreshDragPart = true
	local refreshInvisiblePart = true

	local preactionCFrame
	local preActionSize

	if selectedPart and not itemToUpdate then
		preactionCFrame = selectedPart.CFrame
		preActionSize = selectedPart.Size
	end

	handleWasDragged = true

	local selection = Selection.getFilteredSelection()

	if #selection == 0 then
		resetDragger()
		return
	end

	local isPreviouslyColliding = false
	if plugin.CollisionEnabled then
		invisiblePart.Parent = workspace
		if List.itemsHasItemNotInList(invisiblePart:GetTouchingParts(), selection) then
			isPreviouslyColliding = true
		end
		invisiblePart.Parent = nil
	end

	-- Fast Flag for MOD-652
	if (getFFlagFixTransformScalingSpheresAndCylinders()) then
		-- prevents attmpets to scale cylinders and spheres unevenly by adjusting currentDist
		-- to force uniform scaling on 2 or 3 axes
		currentDist = adjustScalingInCaseOfSpecialParts(selectedPart, currentDist, currentHandle)
	end

	if currentHandle == S_Y_POS then
		local yScale = -Adorn.getYScale()
		currentDist = currentDist * -yScale
		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(yScale * ((originalSize - selectedPart.Size) / 2)))

		local totalDist = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
		local diff = (preactionCFrame.p - selectedPart.CFrame.p).unit

		if plugin.CollisionEnabled and #selectedPart:GetTouchingParts() > 0 then
			selectedPart.Size = preActionSize
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame

			if isPreviouslyColliding then return end

			moveUntilCollideWrapper(selectedPart, 0.00001, nil, diff * -1, totalDist * 2)

			local distanceMoved = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
			local positionDiff = preactionCFrame.p - selectedPart.CFrame.p
			selectedPart.Size = preActionSize - (distanceMoved * getScaleHandleLocalVector(currentHandle) * yScale)
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame - (positionDiff / 2)

		end

		local normal = selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(0, 1, 0)) - selectedPart.CFrame.p
		local cameraDirection = game.Workspace.Camera.CoordinateFrame.lookVector
		local projectedCameraDirection = cameraDirection - (cameraDirection:Dot(normal) * normal)

		local tangent = projectedCameraDirection:Cross(normal).unit

		Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(0, -1, 0)),
					   selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(0, 1, 0)),
					   tangent)


	elseif currentHandle == S_X_POS or
		   currentHandle == S_Z_POS then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(-((originalSize - selectedPart.Size) * 0.5)))

		local totalDist = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
		local diff = (preactionCFrame.p - selectedPart.CFrame.p).unit

		if plugin.CollisionEnabled and #selectedPart:GetTouchingParts() > 0 then
			selectedPart.Size = preActionSize
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame

			if isPreviouslyColliding then return end

			moveUntilCollideWrapper(selectedPart, 0.00001, nil, diff * -1, totalDist * 2)

			local distanceMoved = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
			local positionDiff = preactionCFrame.p - selectedPart.CFrame.p
			selectedPart.Size = preActionSize + (distanceMoved * getScaleHandleLocalVector(currentHandle))
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame - (positionDiff / 2)

		end

		if currentHandle == S_X_POS then
			local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
			local side = Utility.getVector3Sign(localCamera)
			Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		elseif currentHandle == S_Z_POS then
			local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
			local side = Utility.getVector3Sign(localCamera)
			Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)
		end

--		filteredSelectionMetapart.Size = selectedPart.Size
--		filteredSelectionMetapart.CFrame = selectedPart.CFrame

	elseif currentHandle == S_X_NEG or
		   currentHandle == S_Z_NEG then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(((originalSize - selectedPart.Size) * 0.5)))

		local totalDist = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
		local diff = (preactionCFrame.p - selectedPart.CFrame.p).unit

		if plugin.CollisionEnabled and #selectedPart:GetTouchingParts() > 0 then
			selectedPart.Size = preActionSize
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame

			if isPreviouslyColliding then return end

			moveUntilCollideWrapper(selectedPart, 0.00001, nil, diff * -1, totalDist * 2)

			local distanceMoved = Utility.distanceVector3(preactionCFrame.p, selectedPart.CFrame.p)
			local positionDiff = preactionCFrame.p - selectedPart.CFrame.p
			selectedPart.Size = preActionSize - (distanceMoved * getScaleHandleLocalVector(currentHandle))
			if shouldBreakJoints then
				UnjoinSelection()
				BreakJoints(selectedPart)
			end
			selectedPart.CFrame = preactionCFrame - (positionDiff / 2)

		end

		if currentHandle == S_X_NEG then
			local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
			local side = Utility.getVector3Sign(localCamera)
			Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		elseif currentHandle == S_Z_NEG then
			local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
			local side = Utility.getVector3Sign(localCamera)
			Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)
		end


	elseif currentHandle == S_X_POS_Z_POS then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(-((originalSize - selectedPart.Size) / 2)))

		local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
		local side = Utility.getVector3Sign(localCamera)

		Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		Adorn.scaleTwo(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)


	elseif currentHandle == S_X_NEG_Z_POS then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(-((originalSize - selectedPart.Size) / 2) * Vector3.new(-1, 0, 1)))

		local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
		local side = Utility.getVector3Sign(localCamera)

		Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
					   selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
					   selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		Adorn.scaleTwo(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
					   selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
					   selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)

	elseif currentHandle == S_X_NEG_Z_NEG then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(-((originalSize - selectedPart.Size) / 2) * Vector3.new(-1, 0, -1)))

		local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
		local side = Utility.getVector3Sign(localCamera)

		Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
					   selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
					   selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		Adorn.scaleTwo(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
					   selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
					   selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)

	elseif currentHandle == S_X_POS_Z_NEG	then

		if shouldBreakJoints then
			UnjoinSelection()
			BreakJoints(selectedPart)
		end

		selectedPart.Size = snapVector3ByHandle(originalSize + currentDist, currentHandle)
		selectedPart.CFrame = originalCFrame:toWorldSpace(CFrame.new(-((originalSize - selectedPart.Size) / 2) * Vector3.new(1, 0, -1)))

		local localCamera = selectedPart.CFrame:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p)
		local side = Utility.getVector3Sign(localCamera)

		Adorn.scaleOne(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(-1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(1, -1, side.z)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(0, 0, 1)) - selectedPart.CFrame.p)

		Adorn.scaleTwo(selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, -1)),
							selectedPart.CFrame:pointToWorldSpace(selectedPart.Size / 2 * Vector3.new(side.x, -1, 1)),
							selectedPart.CFrame:pointToWorldSpace(side * Vector3.new(1,0,0)) - selectedPart.CFrame.p)
	elseif currentHandle == T_Y_POS then

		local previousPosition = invisiblePart.CFrame

		invisiblePart.CFrame = previousAABBCFrame:toWorldSpace(CFrame.new(currentDist))

		local offset1 = -invisiblePart.CFrame:pointToObjectSpace(secondaryLocation).y - invisiblePart.Size.Y / 2
		local offset2 = -invisiblePart.CFrame:pointToObjectSpace(secondaryLocation).y + invisiblePart.Size.Y / 2

		local snappedOffset1 = roundToNearestGrid(offset1)
		local snappedOffset2 = roundToNearestGrid(offset2)

		local deltaOffset1 = snappedOffset1 - offset1
		local deltaOffset2 = snappedOffset2 - offset2

		local deltaOffset = math.abs(deltaOffset1) <= math.abs(deltaOffset2) and deltaOffset1 or deltaOffset2

		local worldOffset = invisiblePart.CFrame:pointToWorldSpace(Vector3.new(0, deltaOffset, 0))
		invisiblePart.CFrame = invisiblePart.CFrame - invisiblePart.CFrame.p + worldOffset;

		local initialTest = false

		if plugin.CollisionEnabled then

			local positionDiff = invisiblePart.CFrame.p - previousPosition.p
			local totalDist = Utility.distanceVector3(previousPosition.p, invisiblePart.CFrame.p)

			if filteredSelectionMetapart.CanSimulate then
				filteredSelectionMetapart.TranslateFromTo(previousPosition, invisiblePart.CFrame)
				if List.itemsHasItemNotInList(filteredSelectionMetapart:GetTouchingParts(), filteredSelectionMetapart.Children) then
					local unitDiff = positionDiff.Unit
					filteredSelectionMetapart.TranslateFromTo(invisiblePart.CFrame, previousPosition)
					--move until collide
					Collision.moveUntilCollideMetapart(filteredSelectionMetapart, filteredSelectionMetapart.Children, unitDiff, totalDist)
				end
			else
				invisiblePart.Parent = workspace

				if List.itemsHasItemNotInList(invisiblePart:GetTouchingParts(), filteredSelectionMetapart.Children) then

					local unitDiff = positionDiff.Unit
					invisiblePart.CFrame = previousPosition
					moveUntilCollideWrapper(invisiblePart, 0.0002, filteredSelectionMetapart.Children, unitDiff, totalDist)
				end

				invisiblePart.Parent = nil
				filteredSelectionMetapart.TranslateFromTo(previousPosition, invisiblePart.CFrame)
			end

		else
			filteredSelectionMetapart.TranslateFromTo(previousPosition, invisiblePart.CFrame)
		end


	elseif currentHandle == R_XY then
		local halfSize = originalSize * 0.5
		local handleSide = originalCFrame:pointToObjectSpace(initialPos)
		handleSide = handleSide.Z / math.abs(handleSide.Z)
		local radius = math.max(originalSize.X, originalSize.Y)

		local isInside = (originalCFrame:toWorldSpace(CFrame.new(Vector3.new(0,0,halfSize.Z * handleSide))).p - intersectionPoint).magnitude < radius

		local localPosition = originalCFrame:pointToObjectSpace(originalPosition)
		local newPosition = localPosition + currentDist

		local change = math.atan2(newPosition.Y, newPosition.X) - math.atan2(localPosition.Y, localPosition.X)
		local nearestChange = Round.roundToNearest(math.deg(change), isInside and 22.5 or 1)

		local expected = originalCFrame * CFrame.Angles(0, 0, math.rad(nearestChange))

		if filteredSelectionMetapart:IsA("BasePart") then
			filteredSelectionMetapart.CFrame = expected
		elseif filteredSelectionMetapart:IsA("Model") and not filteredSelectionMetapart:IsA("Workspace") then
			local previousCFrame = filteredSelectionMetapart:GetModelCFrame()
			setModelCFrame(filteredSelectionMetapart, expected)
			if plugin.CollisionEnabled and #filteredSelectionMetapart:GetTouchingParts() > 0 then
				setModelCFrame(filteredSelectionMetapart, previousCFrame)
			end
		elseif filteredSelectionMetapart:IsA("Grouping") then
			local previousCFrame = filteredSelectionMetapart.CFrame

			filteredSelectionMetapart.CFrame = expected

			if plugin.CollisionEnabled and #filteredSelectionMetapart:GetTouchingParts() > 0 then
				filteredSelectionMetapart.CFrame = previousCFrame
			end
		end

		if filteredSelectionMetapart and
			(not plugin.CollisionEnabled or
				not List.itemsHasItemNotInList(filteredSelectionMetapart:GetTouchingParts(), selection)) then
			local planeNormal = (originalCFrame:pointToWorldSpace(Vector3.new(0, 0, 1)) - originalCFrame.p).Unit

			local initialAngle = (originalCFrame:pointToObjectSpace(initialPos) * Vector3.new(1, 1, 0)).unit
			local zVector = Vector3.new(0, -1, 0)

			local out = cosineSimilarity(zVector, initialAngle) --* (initialAngle.X > 0 and 1 or -1)
			local rotationalOffset = out
			if (initialAngle.X > 0) then
				rotationalOffset = rotationalOffset + 90
			else
				if (initialAngle.Y > 0) then
					rotationalOffset = rotationalOffset + 180 + 45
				else
					rotationalOffset = rotationalOffset - 45
				end
			end

			Adorn.showRotate(originalCFrame:toWorldSpace(CFrame.new(Vector3.new(0,0,halfSize.Z * handleSide)))* CFrame.Angles(math.rad(0), math.rad(0),math.rad(rotationalOffset) ),
					radius,
					nearestChange, intersectionPoint)
		end

	elseif currentHandle == R_XZ then

		local halfSize = originalSize * 0.5
		local handleSide = originalCFrame:pointToObjectSpace(initialPos)
		handleSide = handleSide.Y / math.abs(handleSide.Y)
		local radius = math.max(originalSize.X, originalSize.Z)

		local isInside = (originalCFrame:toWorldSpace(CFrame.new(Vector3.new(0,halfSize.Y * handleSide,0))).p - intersectionPoint).magnitude < radius

		local localPosition = originalCFrame:pointToObjectSpace(originalPosition)
		local newPosition = localPosition + currentDist

		local change = math.atan2(newPosition.Z, newPosition.X) - math.atan2(localPosition.Z, localPosition.X)
		local nearestChange = Round.roundToNearest(math.deg(change), isInside and 22.5 or 1)

		local expected = originalCFrame * CFrame.Angles(0, -math.rad(nearestChange), 0)

		if filteredSelectionMetapart:IsA("BasePart") then
			filteredSelectionMetapart.CFrame = expected
		elseif filteredSelectionMetapart:IsA("Grouping") or (filteredSelectionMetapart:IsA("Model") and not filteredSelectionMetapart:IsA("Workspace")) then
			local previousCFrame = filteredSelectionMetapart.CFrame

			filteredSelectionMetapart.CFrame = expected

			if plugin.CollisionEnabled and #filteredSelectionMetapart:GetTouchingParts() > 0 then
				filteredSelectionMetapart.CFrame = previousCFrame
			end
		end

		if filteredSelectionMetapart and
			(not plugin.CollisionEnabled or
				not List.itemsHasItemNotInList(filteredSelectionMetapart:GetTouchingParts(), selection)) then
			local planeNormal = (originalCFrame:pointToWorldSpace(Vector3.new(currentHandle == R_YZ and 1 or 0, currentHandle == R_XZ and 1 or 0, currentHandle == R_XY and 1 or 0)) - originalCFrame.p).Unit

			local initialAngle = (originalCFrame:pointToObjectSpace(initialPos) * Vector3.new(1, 0, 1)).unit
			local zVector = Vector3.new(0, 0, -1)

			local out = cosineSimilarity(zVector, initialAngle) * (initialAngle.X > 0 and 1 or -1)
			local rotationalOffset = out + 90

			Adorn.showRotate(originalCFrame:toWorldSpace(CFrame.new(Vector3.new(0,halfSize.Y * handleSide,0)))* CFrame.Angles(math.rad(90),0 ,math.rad(rotationalOffset) ),
				radius,
				nearestChange, intersectionPoint)
		end

	elseif currentHandle == R_YZ then

		local halfSize = originalSize * 0.5

		local handleSide = originalCFrame:pointToObjectSpace(initialPos)
		handleSide = handleSide.X / math.abs(handleSide.X)
		local radius = math.max(originalSize.Y, originalSize.Z)

		local isInside = (originalCFrame:toWorldSpace(CFrame.new(Vector3.new(halfSize.X * handleSide,0,0))).p - intersectionPoint).magnitude < radius

		local localPosition = originalCFrame:pointToObjectSpace(originalPosition)
		local newPosition = localPosition + currentDist

		local change = math.atan2(newPosition.Z, newPosition.Y) - math.atan2(localPosition.Z, localPosition.Y)
		local nearestChange = Round.roundToNearest(math.deg(change), isInside and 22.5 or 1)
		local expected = originalCFrame * CFrame.Angles(math.rad(nearestChange), 0, 0)

		if filteredSelectionMetapart:IsA("BasePart") then
			filteredSelectionMetapart.CFrame = expected
		elseif filteredSelectionMetapart:IsA("Model") and not filteredSelectionMetapart:IsA("Workspace") then
			local previousCFrame = filteredSelectionMetapart:GetModelCFrame()
			setModelCFrame(filteredSelectionMetapart, expected)
			if plugin.CollisionEnabled and #filteredSelectionMetapart:GetTouchingParts() > 0 then
				setModelCFrame(filteredSelectionMetapart, previousCFrame)
			end
		elseif filteredSelectionMetapart:IsA("Grouping") then
			local previousCFrame = filteredSelectionMetapart.CFrame
			filteredSelectionMetapart.CFrame = expected
			if plugin.CollisionEnabled and #filteredSelectionMetapart:GetTouchingParts() > 0 then
				filteredSelectionMetapart.CFrame = previousCFrame
			end
		end

		--rotation adorn

		if filteredSelectionMetapart and
			(not plugin.CollisionEnabled or
				not List.itemsHasItemNotInList(filteredSelectionMetapart:GetTouchingParts(), selection)) then
			local planeNormal = (originalCFrame:pointToWorldSpace(Vector3.new(1, 0, 0)) - originalCFrame.p).Unit

			local initialAngle = (originalCFrame:pointToObjectSpace(initialPos) * Vector3.new(0, 1, 1)).unit
			local zVector = Vector3.new(0, 0, -1)

			local out = cosineSimilarity(zVector, initialAngle) * (initialAngle.Y > 0 and 1 or -1)
			local rotationalOffset = out + 180

			Adorn.showRotate(originalCFrame:toWorldSpace(CFrame.new(Vector3.new(halfSize.X * handleSide,0,0)))* CFrame.Angles(0,math.rad(90) ,math.rad(rotationalOffset) ),
							 radius,
							 nearestChange,
							 intersectionPoint)

		end

	elseif currentHandle == H_PLANE and not currentlyOverHandle then
		Adorn.setAllAdornVisibility(false)
		if not planeDragging then
			if not Adorn.isPlaneSelectingModeOn() then return end
			planeDragging = true

			if not planeObject then
				planeObject = Instance.new("Part", cg)
				planeObject.Size = Vector3.new(50, 50, 0.01)
				planeObject.Position = Vector3.new(0,0,0)
				planeObject.Transparency = 1
			end

			if not holoBox then
				holoBox = Instance.new("BoxHandleAdornment", cg)
				holoBox.Visible = false
				holoBox.Adornee = planeObject
				holoBox.Size = holoBox.Adornee.Size
				holoBox.Transparency = 0.6
				holoBox.Color3 = Color3.new(38.0 / 255.0, 136.0 / 255.0, 240.0 / 255.0)
			end
		end
	else
		allowAdornUpdate = false
	end

	if plugin.CollisionEnabled and #game:GetService("Selection"):Get() == 1 then
		if currentHandle == S_Y_POS or
		   currentHandle == S_Z_POS or
		   currentHandle == S_X_NEG or
		   currentHandle == S_Z_NEG or
		   currentHandle == S_X_POS_Z_POS or
		   currentHandle == S_X_NEG_Z_POS or
		   currentHandle == S_X_NEG_Z_NEG or
		   currentHandle == S_X_POS_Z_NEG or
		   currentHandle == R_XY or
		   currentHandle == R_XZ or
		   currentHandle == R_YZ then
			if selectedPart and List.itemsHasItemNotInList(selectedPart:GetTouchingParts(), filteredSelection) then
				if preactionCFrame then
					selectedPart.CFrame = preactionCFrame
				end
				if preActionSize then
					selectedPart.Size = preActionSize
				end
			end
		end
	end

	if (selectedPart) then
		updatePivotAndChildAttachments(selectedPart, preActionSize, selectedPart.Size)
	end

	if allowAdornUpdate then
		updateDragPart()
	end

	if currentHandle ~= R_XY and
		currentHandle ~= R_XZ and
		currentHandle ~= R_YZ then
		updateInvisiblePart()
	end

	if currentHandle == T_Y_POS then
		updateRotatePart()
	end
	adornmentUpdateNeeded = true
end

function updateDragPart()

	if not dragPart then
		dragPart = Instance.new("Part", nil)
		dragPart.Name = "DragParte1b1aec5"
		dragPart.BottomSurface = Enum.SurfaceType.Smooth
		dragPart.TopSurface = Enum.SurfaceType.Smooth
		dragPart.Transparency = 1
		if shouldBreakJoints then
			BreakJoints(dragPart)
		end
	end

	if not dragPartHoloBox then
		dragPartHoloBox = Instance.new("BoxHandleAdornment", cg)
		dragPartHoloBox.Visible = false
		dragPartHoloBox.Color3 = Color3.new(38.0 / 255.0, 136.0 / 255.0, 240.0 / 255.0)
		dragPartHoloBox.Transparency = .5
		dragPartHoloBox.AlwaysOnTop = true
	end

	if dragPart then
		if #game:GetService("Selection"):Get() == 1 then
			local mainPart = Metapart.convertToPart(game:GetService("Selection"):Get()[1])
			dragPart.Size = mainPart.Size
			dragPart.CFrame = mainPart.CFrame
		else
			dragPart.Size = invisiblePart.Size
			dragPart.CFrame = invisiblePart.CFrame
		end

		dragPart.Name = "DragParte1b1aec5"
		dragPart.Archivable = false
		dragPart.Parent = nil
		dragPart.BottomSurface = Enum.SurfaceType.Smooth
		dragPart.TopSurface = Enum.SurfaceType.Smooth
		if shouldBreakJoints then
			BreakJoints(dragPart)
		end
	end

	if dragPartHoloBox and selectedPart then
		dragPartHoloBox.Adornee = dragPart
		dragPartHoloBox.Size = dragPartHoloBox.Adornee.Size-- + Vector3.new(.01, .01, .01)
		dragPartHoloBox.AlwaysOnTop = true
		dragPartHoloBox.CFrame = dragPart.CFrame - dragPart.CFrame.p
		--dragPartHoloBox.Color3 = Color3.new(.2, .5, .1)
		--dragPartHoloBox.Visible = true

		--dragPartHoloBox.DrawFull = true
		--Remove for Demo - dragPartHoloBox.Visible = true
	end
end

function grabPart()
	--if not selectedPart then return end

	updateInvisiblePart()

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()

	if not filteredSelectionMetapart then return end

	freeDragging = true
	originalSize = filteredSelectionMetapart.Size
	originalCFrame = filteredSelectionMetapart.CFrame

	previousAABBCFrame = filteredSelectionMetapart.PlaneAlignedCFrame

	local extent = getBestExtentRotation()
	if not extent then return end

	originalDragPartOrientation = extent + previousAABBCFrame.p

	updateDragPart()

	setPartRotation(dragPart, originalDragPartOrientation)
	Extent.setPartCFrameToExtents(dragPart, originalDragPartOrientation)
end

function getAllFaceNormals(part)
	local normals = {}

	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(1,0,0)) - part.CFrame.p).Unit)
	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(-1,0,0)) - part.CFrame.p).Unit)
	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(0,1,0)) - part.CFrame.p).Unit)
	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(0,-1,0)) - part.CFrame.p).Unit)
	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(0,0,1)) - part.CFrame.p).Unit)
	table.insert(normals, (part.CFrame:pointToWorldSpace(Vector3.new(0,0,-1)) - part.CFrame.p).Unit)

	return normals
end

function getDirectedNormalsFromPart(part, vect)
	local faceNormals = getAllFaceNormals(part)

	local closestNormals = {}

	local planeNormal = invisiblePart.CFrame:pointToWorldSpace(Vector3.new(0,1,0)) - invisiblePart.Position
	local perpPlaneNormal = planeNormal:Cross(vect) / planeNormal:Cross(vect).Magnitude

	for i,v in ipairs(faceNormals) do

		local projection = projectVectorToPlane(v, planeNormal)
		projection = projectVectorToPlane(projection, perpPlaneNormal).Unit

		if FuzzyMath.fuzzyCompareVector3(projection, vect) then
			table.insert(closestNormals, v)
		end
	end

	return closestNormals


	--project all face normals to workplaneFrame
	--project all normals to plane perpendiculat to workplane with direction vect

	--check which normal units are equal to vect unir
end

function getClosestNormalFromPart(part, vect)
	local bestSim = nil
	local bestNormal = {}

	for i = 1, 3 do
		for j = 1, 2 do
			local normalLocal = Vector3.new((i == 1 and 1 or 0), (i == 2 and 1 or 0), (i == 3 and 1 or 0)) * (j == 1 and 1 or -1)
			local normalWorld = part.CFrame:pointToWorldSpace(normalLocal) - part.CFrame.p

			local sim = cosineSimilarity(normalWorld.Unit, vect)

			if bestSim == nil or sim < bestSim then
				bestSim = sim
				bestNormal = {normalWorld.Unit}
			elseif sim == bestSim then
				table.insert(bestNormal, normalWorld.Unit)
			end
		end
	end

	if bestSim ~= bestSim then
		for _,v in ipairs(bestNormal) do
			v = v * -1.0
		end
	end

	return bestNormal
end

function getFirstPart(instances)
	local returnPart
	for i, v in ipairs(instances) do
		if v:IsA("BasePart") then return v end
		returnPart = getFirstPart(v:GetChildren())
		if returnPart then return returnPart end
	end
	return nil
end

function getBestExtentRotation()
	--get primary part rotation
	local selection = game:GetService("Selection"):Get()
	if #selection == 0 then return CFrame.new() end

	for i, v in ipairs(selection) do
		if v:IsA("Model") and not v:IsA("Workspace") then
			if v.PrimaryPart then return v.PrimaryPart.CFrame end
			local primaryPart = getFirstPart(selection)

			if not primaryPart then return CFrame.new() end
			return primaryPart.CFrame

		elseif v:IsA("BasePart") then
			return v.CFrame
		end
	end

	--not parts to drag
	return nil
end

function getNormalOfFace(collidedPart, collidedLocation)
	if not collidedPart or not collidedLocation then return end

	local halfSize = collidedPart.Size / 2
	local localCollisionLocation = collidedPart.CFrame:pointToObjectSpace(collidedLocation)

	local localNormal = Vector3.new(0,0,0)
	if FuzzyMath.fuzzyCompare(localCollisionLocation.X, halfSize.X) then
		--right
		localNormal = Vector3.new(1, 0, 0)
	elseif FuzzyMath.fuzzyCompare(localCollisionLocation.X, -halfSize.X) then
		--left
		localNormal = Vector3.new(-1, 0, 0)
	elseif FuzzyMath.fuzzyCompare(localCollisionLocation.Y, halfSize.Y) then
		--top
		localNormal = Vector3.new(0, 1, 0)
	elseif FuzzyMath.fuzzyCompare(localCollisionLocation.Y, -halfSize.Y) then
		--bottom
		localNormal = Vector3.new(0, -1, 0)
	elseif FuzzyMath.fuzzyCompare(localCollisionLocation.Z, halfSize.Z) then
		--back
		localNormal = Vector3.new(0, 0, 1)
	elseif FuzzyMath.fuzzyCompare(localCollisionLocation.Z, -halfSize.Z) then
		--front
		localNormal = Vector3.new(0, 0, -1)
	end

	return collidedPart.CFrame:pointToWorldSpace(localNormal) - collidedPart.CFrame.p
end

function getNormalFromClosestPoint(part, position)
	if not part or not position then return nil end

	local localPoint = part.CFrame:pointToObjectSpace(position)
	local halfSize = part.Size / 2
	local absLocalPoint = Utility.absVector3(localPoint)

	local xz = halfSize.x / halfSize.z
	local pointXZ = absLocalPoint.x / absLocalPoint.z

	local direction = Vector3.new(0,0,0)

	if pointXZ > xz then
		local xy = halfSize.x / halfSize.y
		local pointXY = absLocalPoint.x / absLocalPoint.y
		if pointXY > xy then
			if localPoint.x < 0 then
				direction = Vector3.new(-1,0,0)
			else
				direction = Vector3.new(1,0,0)
			end
		else
			if localPoint.y < 0 then
				direction = Vector3.new(0,-1,0)
			else
				direction = Vector3.new(0,1,0)
			end
		end
	else
		local yz = halfSize.y / halfSize.z
		local pointYZ = absLocalPoint.y / absLocalPoint.z
		if pointYZ > yz then
			if localPoint.y < 0 then
				direction = Vector3.new(0,-1,0)
			else
				direction = Vector3.new(0,1,0)
			end
		else
			if localPoint.z < 0 then
				direction = Vector3.new(0,0,-1)
			else
				direction = Vector3.new(0,0,1)
			end
		end
	end

	return (part.CFrame:pointToWorldSpace(direction) - part.CFrame.p).Unit

end

function normalExistsInTable(t, normal)
	for i,v in pairs(t) do
		if v[2] == normal then
			return true
		end
	end
	return false
end


function getNormalOfCollidingFace(movingPos, collidingPos, planeNormal)
	local v = planeNormal * -1
	local w = collidingPos - movingPos

	local c1 = w:Dot(v)

	local c2 = v:Dot(v)

	local b = c1 / c2
	local Pb = movingPos + (b * v)

	return Pb
end

local sanitizationPrecision = 1000000

function sanitizeFloat(value)
	return value > 0.0 and (math.ceil((value * sanitizationPrecision) - 0.5) / sanitizationPrecision) or (math.floor((value * sanitizationPrecision) + 0.5) / sanitizationPrecision)
end

function sanitizeVector3(value)
	return Vector3.new(sanitizeFloat(value.x),
						sanitizeFloat(value.y),
						sanitizeFloat(value.z))
end

function sanitizeCFrame(value)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = value:components()
	return CFrame.new(
		sanitizeFloat(x),
		sanitizeFloat(y),
		sanitizeFloat(z),
		r00,
		r01,
		r02,
		r10,
		r11,
		r12,
		r20,
		r21,
		r22)
end

local firstMove = true
local partMoved = false

function movePart(delta, collision)
	Adorn.setAllAdornVisibility(false)

	if not secondaryPart then
		return
	end

	if not dragPart then
		return
	end

	partMoved = true

	adornmentUpdateNeeded = true
	local selection = getCurrentSelectionWithChildren()
	if not setAnchoredStateForMovingParts then
		setAnchoredStateForMovingParts = true
		for i, v in ipairs(selection) do
			states[i] = v.Anchored
			v.Anchored = true
		end
	end

	local extentRotation = getBestExtentRotation()

	if not extentRotation or not selectedPart then return end

	setPartRotation(dragPart, #selection > 1 and workplaneFrame or extentRotation)

	if firstMove then -- this is expensive, only doing first time
		firstMove = false
		Extent.setPartCFrameToExtents(dragPart, dragPart.CFrame)
	end
	local initialPos = dragPart.CFrame

	if not dragFromToolbox then
		local deltaLocal = invisiblePart.CFrame:pointToObjectSpace(delta + dragPart.Position)

		deltaLocal = deltaLocal * Vector3.new(1, 0, 1)
		delta = invisiblePart.CFrame:pointToWorldSpace(deltaLocal)
		delta = delta - invisiblePart.Position
	end

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()

	setPartPosition(dragPart, previousAABBCFrame.p + delta)

	if shouldBreakJoints then
		UnjoinSelection()
	end

	local objectCFrame = workplaneFrame:toObjectSpace(dragPart.CFrame)

	local verts = {}

	local halfSize = selectedPart.Size / 2
	local minSnappingDist = 100
	local closestVectorIndex = nil

	local dragHalf = dragPart.Size / 2
	--Snap bounding box verts

	verts[1] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new(-1,-1,-1)))
	verts[2] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new(-1,-1, 1)))
	verts[3] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new(-1, 1,-1)))
	verts[4] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new(-1, 1, 1)))
	verts[5] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new( 1,-1,-1)))
	verts[6] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new( 1,-1, 1)))
	verts[7] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new( 1, 1,-1)))
	verts[8] = workplaneFrame:pointToObjectSpace(dragPart.CFrame:pointToWorldSpace(dragHalf * Vector3.new( 1, 1, 1)))

	local minXDist = 100
	local minYDist = 100
	local minZDist = 100

	local minSnapMovementX = 0
	local minSnapMovementY = 0
	local minSnapMovementZ = 0

	for i = 1, #verts do
		local xDist = verts[i].x - roundToNearestGrid(verts[i].x)
		local yDist = verts[i].y - roundToNearestGrid(verts[i].y)
		local zDist = verts[i].z - roundToNearestGrid(verts[i].z)
		if math.abs(xDist) < minXDist then
			minXDist = math.abs(xDist)
			minSnapMovementX = xDist
		end
		if math.abs(yDist) < minYDist then
			minYDist = math.abs(yDist)
			minSnapMovementY = yDist
		end
		if math.abs(zDist) < minZDist then
			minZDist = math.abs(zDist)
			minSnapMovementZ = zDist
		end
	end

	local snappedDelta = Vector3.new(minSnapMovementX, minSnapMovementY, minSnapMovementZ)

	snappedDelta = snappedDelta * Vector3.new(1, 0, 1)

	snappedDelta = sanitizeVector3(snappedDelta)

	objectCFrame = objectCFrame - snappedDelta

	objectCFrame = sanitizeCFrame(objectCFrame)


	if collision and not dragFromToolbox then

		local planeNormal = invisiblePart.CFrame:pointToWorldSpace(Vector3.new(0,1,0)) - invisiblePart.Position

		setPartPosition(dragPart, workplaneFrame:toWorldSpace(objectCFrame).p)
		--setPartRotation(dragPart, invisiblePart.CFrame)
		if not originalDragPartOrientation then return end
		setPartRotation(dragPart, #selection > 1 and workplaneFrame or originalDragPartOrientation)--originalDragPartOrientation) USE THIS FOR LOCAL SPACE DRAG

		local preSafeMove = dragPart.CFrame

		 --TODO, switch to this
		table.insert(selection, dragPart)

		dragPart.Parent = workspace

		dragPart.CFrame = initialPos

		dragPart.CFrame = preSafeMove

		if List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) then

			local dragVector = (dragPart.CFrame.p - initialPos.p).Unit
			if dragVector.x ~= dragVector.x then
				dragVector = Vector3.new(0,0,0)
			end

			local partNormalTable = {}

			safeMoveWrapper(dragPart, 0.0002, selection, dragVector * -1)

			if Utility.distanceVector3(initialPos.p, preSafeMove.p) <= Utility.distanceVector3(dragPart.CFrame.p, preSafeMove.p) then
				dragPart.CFrame = initialPos
			end

			local afterInitialSafeMovePos = dragPart.CFrame

			dragPart.CFrame = dragPart.CFrame + (dragVector * .0001)
			--move back in slightly (for collision purposes
			local i = 0

			while not List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) and i < 100 do
				dragPart.CFrame = dragPart.CFrame + (dragVector * .0001)
				i = i + 1
			end

			local collideFrame = dragPart.CFrame

			local collidingParts = List.filterOutItems(selection, dragPart:GetTouchingParts())
			--consolidate normals

			local collidingPartsCFrameList = {}

			--Iterate over colliding parts to consolidate colliding normals
			local beginTime = tick()
			for _,v in pairs(collidingParts) do
				--checked = checked + 1
				local rotation = v.CFrame - v.CFrame.p
				--if not existsInTable(collidingPartsCFrameList, rotation) then
					--innerLoop = innerLoop + 1
				table.insert(collidingPartsCFrameList, rotation)

				local Pb = getNormalOfCollidingFace(dragPart.CFrame.p, v.CFrame.p, planeNormal)
				local faceNormal = getNormalFromClosestPoint(v, Pb).Unit

				--constraining to plane
				faceNormal = faceNormal - (faceNormal:Dot(planeNormal.Unit) * planeNormal.Unit)

				--round please
				faceNormal = Vector3.new(FuzzyMath.fuzzyCompare(0,faceNormal.x) and 0 or faceNormal.x, FuzzyMath.fuzzyCompare(0,faceNormal.y) and 0 or faceNormal.y, FuzzyMath.fuzzyCompare(0,faceNormal.z) and 0 or faceNormal.z)
				faceNormal = Round.roundVector3ToNearest(faceNormal, 0.0001)

				if not normalExistsInTable(partNormalTable, faceNormal) then
					table.insert(partNormalTable, {v, faceNormal})
				end
			end

			local endTime = tick()

			--for each part safe move with white list out by normal(even if not colliding)
			local finalPositionTable = {}

			local localFaceNormalTable = {}
			for _,v in pairs(partNormalTable) do

				dragPart.CFrame = initialPos
				local lowerBounds, upperBounds = Extent.getPartBounds(dragPart, v[1].CFrame)
				lowerBounds = v[1].CFrame:pointToObjectSpace(lowerBounds)
				upperBounds = v[1].CFrame:pointToObjectSpace(upperBounds)
				dragPart.CFrame = preSafeMove

				local lowerBounds2, upperBounds2 = Extent.getPartBounds(dragPart, v[1].CFrame)
				lowerBounds2 = v[1].CFrame:pointToObjectSpace(lowerBounds2)
				upperBounds2 = v[1].CFrame:pointToObjectSpace(upperBounds2)

				lowerBounds, upperBounds = Extent.unionVector3NoSpaceChange(lowerBounds2, lowerBounds, upperBounds)
				lowerBounds, upperBounds = Extent.unionVector3NoSpaceChange(upperBounds2, lowerBounds, upperBounds)

				local p1 = afterInitialSafeMovePos.p

				setPartPosition(dragPart, v[1].CFrame.p)
				safeMoveWhiteList(dragPart, v[2], {v[1]})
				--dragPart:SafeMoveWhiteList(v[2], {v[1]})

				local p2 = dragPart.CFrame.p

				p1 = Round.roundVector3ToNearest(p1, 0.0001)
				p2 = Round.roundVector3ToNearest(p2, 0.0001)

				local p3 = (p1 - p2).Unit

				if Utility.distanceVector3(preSafeMove.p, afterInitialSafeMovePos.p - p3) <
					Utility.distanceVector3(preSafeMove.p, afterInitialSafeMovePos.p + p3) then
					p3 = p3 * -1
				end

				--project to plane

				p3 = p3 - (p3:Dot(planeNormal.Unit) * planeNormal.Unit)

				p3 = getClosestNormalFromPart(v[1], p3)
				if #p3 > 0 then
					p3 = p3[1]
				else
					p3 = nil
				end
				--zero out
				p3 = Vector3.new(FuzzyMath.fuzzyCompare(0,p3.x) and 0 or p3.x, FuzzyMath.fuzzyCompare(0,p3.y) and 0 or p3.y, FuzzyMath.fuzzyCompare(0,p3.z) and 0 or p3.z)

				setPartPosition(dragPart, afterInitialSafeMovePos.p - v[2])
				safeMoveWhiteList(dragPart, p3, {v[1]})
				--dragPart:SafeMoveWhiteList(p3, {v[1]})
				local distToTest = Utility.distanceVector3(dragPart.CFrame.p, preSafeMove)

				dragPart.CFrame = preSafeMove

				safeMoveWhiteList(dragPart, v[2], {v[1]})

				local secondDist = Utility.distanceVector3(dragPart.CFrame.p, afterInitialSafeMovePos)

				if secondDist < distToTest then
					distToTest = secondDist
				end

				dragPart.CFrame = afterInitialSafeMovePos

				local collSel = game.Selection:Get()
				table.insert(collSel, v[1])

				if not moveUntilCollideWrapper(dragPart, 0.0002, collSel, p3, distToTest) then
					local currentLocation = dragPart.CFrame.p
					dragPart.CFrame = preSafeMove
					local moveVector = (dragPart.CFrame.p - currentLocation).Unit
					safeMoveWrapper(dragPart, 0.123, selection, v[2])

				else
					local distTraveled = Utility.distanceVector3(dragPart.CFrame.p, afterInitialSafeMovePos.p)
				end

				local firstPosition = nil
				local localPosition = v[1].CFrame:pointToObjectSpace(dragPart.CFrame.p)

				local loE = vector3LessThanOrEqualTo(localPosition, upperBounds)
				local goE = vector3GreaterThanOrEqualTo(localPosition, lowerBounds)

				--dont remember what loE was for
				--loE = true

				if loE and goE then
					if not List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) then
						table.insert(finalPositionTable, dragPart.CFrame.p)
					else
						firstPosition = dragPart.CFrame.p
					end
				end

				dragPart.CFrame = preSafeMove
				--dragPart:SafeMove(v[2], selection)
				safeMoveWrapper(dragPart, 0.0002, selection, v[2])
				localPosition = v[1].CFrame:pointToObjectSpace(dragPart.CFrame.p)
				if vector3LessThanOrEqualTo(localPosition, upperBounds) and vector3GreaterThanOrEqualTo(localPosition, lowerBounds) then
					if not List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) then
						table.insert(finalPositionTable, dragPart.CFrame.p)
					end
				end

				--try moving out by the closest movingPart face normal

				--getClosest face normal
				local normals = getDirectedNormalsFromPart(dragPart, v[2])
				if firstPosition then
					for _,vNorm in pairs(normals) do
						if not List.itemExistsInList(vNorm, localFaceNormalTable) then
							table.insert(localFaceNormalTable, vNorm)
							setPartPosition(dragPart, firstPosition)
							safeMoveWrapper(dragPart, 0.0002, selection, vNorm)
							localPosition = v[1].CFrame:pointToObjectSpace(dragPart.CFrame.p)
							if not List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) then
								table.insert(finalPositionTable, dragPart.CFrame.p)
							end
						end
					end
				end
			end
			local tick4 = tick()

			local closestPos = initialPos.p
			local closestDist = Utility.distanceVector3(closestPos, preSafeMove.p)

			for _,v in pairs(finalPositionTable) do

				local testingDist = Utility.distanceVector3(v, preSafeMove.p)

				if testingDist < closestDist then
					closestDist = testingDist
					closestPos = v
				end
			end

			setPartPosition(dragPart, closestPos)

			--if dragPart:IsColliding(0.0001, selection) then
			--	setPartPosition(dragPart, afterInitialSafeMovePos.p)
			--end

			----]]COLLISION CORRECT END

		end


		if Utility.distanceVector3(dragPart.CFrame.p, preSafeMove.p) > Utility.distanceVector3(initialPos.p, preSafeMove.p) then
			setPartPosition(dragPart, initialPos.p)
		end

		--local selection = getCurrentSelectionWithChildren()
		if List.itemsHasItemNotInList(dragPart:GetTouchingParts(), selection) then
			local coll = List.filterOutItems(selection, dragPart:GetTouchingParts())

			dragPart.CFrame = initialPos
		end

		dragPart.Parent = nil

		local castOffset = 0.1
		local threshHold = 20 + castOffset

	else

		local newPosition = workplaneFrame:pointToWorldSpace(objectCFrame.p)
		newPosition = sanitizeVector3(newPosition)
		dragPart.CFrame = dragPart.CFrame - dragPart.CFrame.p + newPosition

		if dragFromToolbox then
			local ini1 = dragPart.CFrame.p
			dragPart.Parent = game.Workspace

			safeMoveWrapper(dragPart, 0.0002, game.Selection:Get(), Vector3.new(0, 1, 0))
			dragPart.Parent = nil
			local ini2 = dragPart.CFrame.p

			dragFromToolbox = false
		end

	end

	filteredSelectionMetapart.TranslateFromTo(initialPos, dragPart.CFrame)
end

function planeDrag()
	Adorn.setAllAdornVisibility(false)

	local ray = mouse.UnitRay
	ray = Ray.new(ray.Origin, ray.Direction * 800)

	local part, tmpLocation = game.Workspace:FindPartOnRay(ray)

	if not part or part:IsA("Terrain") then return end
	holoBox.Visible = true

	local location = part and rayBoxIntersection(ray, part.CFrame, part.Size)

	if part and location then

			local localLocation = part.CFrame:pointToObjectSpace(location)

			local v0, v1, v2 = nil

			local halfSize = part.Size /2

			local planeSize = Vector3.new(50, 50, 0.01)
			local centerPoint = location

			planeObject.CFrame = part.CFrame
			planeObject.CFrame = planeObject.CFrame * CFrame.Angles(0, math.rad(90), 0)

			if FuzzyMath.fuzzyCompare(math.abs(localLocation.X), halfSize.X) then

				v0 = localLocation + Vector3.new(0,0,1)
				v1 = localLocation + Vector3.new(0,1,1)
				v2 = localLocation + Vector3.new(0,1,0)

				if FuzzyMath.fuzzyCompare(localLocation.X, halfSize.X) then
					planeSize = Vector3.new(part.Size.z, part.Size.y, 0.01)
					centerPoint = Vector3.new(halfSize.x, 0, 0)
				else
					planeSize = Vector3.new(part.Size.z, part.Size.y, 0.01)
					centerPoint = Vector3.new(-halfSize.x, 0, 0)
				end

			elseif FuzzyMath.fuzzyCompare(math.abs(localLocation.Y), halfSize.Y) then

				v0 = localLocation + Vector3.new(0,0,1)
				v1 = localLocation + Vector3.new(1,0,1)
				v2 = localLocation + Vector3.new(1,0,0)

				planeObject.CFrame = planeObject.CFrame * CFrame.Angles(math.rad(90), 0, 0)

				if FuzzyMath.fuzzyCompare(localLocation.Y, halfSize.Y) then
					planeSize = Vector3.new(part.Size.z, part.Size.x, 0.01)
					centerPoint = Vector3.new(0, halfSize.y, 0)
				else
					planeSize = Vector3.new(part.Size.z, part.Size.x, 0.01)
					centerPoint = Vector3.new(0, -halfSize.y, 0)
				end

			elseif FuzzyMath.fuzzyCompare(math.abs(localLocation.Z), halfSize.Z) then

				v0 = localLocation + Vector3.new(0,1,0)
				v1 = localLocation + Vector3.new(1,1,0)
				v2 = localLocation + Vector3.new(1,0,0)

				planeObject.CFrame = planeObject.CFrame * CFrame.Angles(0, math.rad(90), 0)

				if FuzzyMath.fuzzyCompare(localLocation.Z, halfSize.Z) then
					planeSize = Vector3.new(part.Size.x, part.Size.y, 0.01)
					centerPoint = Vector3.new(0, 0, halfSize.z)
				else
					planeSize = Vector3.new(part.Size.x, part.Size.y, 0.01)
					centerPoint = Vector3.new(0, 0, -halfSize.z)
				end

			end

--[[ CSG Changes
			planeSize = Vector3.new(5, 5, 0.2)
			centerPoint = location
			planeObject.CFrame = CFrame.new(Vector3.new(0,0,0), castNormal)
--]]

			if v0 and v1 and v2 then
				local partDist = part.CFrame:pointToObjectSpace(location) - localLocation
				local v0local = v0 + partDist
				local v1local = v1 + partDist
				local v2local = v2 + partDist
				v0 = part.CFrame:pointToWorldSpace(v0)
				v1 = part.CFrame:pointToWorldSpace(v1)
				v2 = part.CFrame:pointToWorldSpace(v2)

				v0local = part.CFrame:pointToWorldSpace(v0local)
				v1local = part.CFrame:pointToWorldSpace(v1local)
				v2local = part.CFrame:pointToWorldSpace(v2local)

				baseDragPlane = createPlane(v0, v1, v2)
				dragPlane = createPlane(v0local, v1local, v2local)
--[[ CSG Changes
				baseDragPlane.normal = castNormal
				dragPlane.normal = castNormal
--]]
				centerPoint = part.CFrame:pointToWorldSpace(centerPoint)--remove with CSG Changes

				planeObject.CFrame = planeObject.CFrame - planeObject.CFrame.p + centerPoint

				planeObject.Size = planeSize
				holoBox.Size = planeSize

			end

			local halfSize = part.Size * 0.5
			local corner = localLocation / Utility.absVector3(localLocation)
			local centerFrame = part.CFrame - part.CFrame.p + (part.CFrame:pointToWorldSpace(halfSize * corner))
			--localLocation

			Adorn.drawPlaneCenter(centerFrame)

--[[CSG Changes
			planeObject.CFrame = planeObject.CFrame - planeObject.CFrame.p + location
--]]

		end

end

function freeDrag()
	if clickOnUpdate then
		selectPart()
		clickOnUpdate = false
		return
	end

	if planeDragging then
		planeDrag()
		return
	end

	if not freeDragging then
		hasStartedDragging = true
		RubberBand.updateRubberBand(Vector2.new(mouse.X, mouse.Y))
		return
	end

	castPlane = nil

	local currentRay = mouse.UnitRay
	currentRay = Ray.new(currentRay.Origin, currentRay.Direction * 800)

	if not dragPlane then return end

	local colPoint = rayPlaneIntersection(currentRay, dragPlane)

	if not dragFromToolbox then
		local pTest = (colPoint - currentRay.Origin)
		pTest = pTest / currentRay.Unit.Direction
		if pTest.X < 0 or pTest.Y < 0 or pTest.Z < 0 then
			return
		end
	end

	if dragFromToolbox then
		colPoint = rayPlaneIntersection(currentRay, baseDragPlane)
		local colPart, colLocation = workspace:FindPartOnRayWithIgnoreList(currentRay, game.Selection:Get())
		local cameraPos = workspace.CurrentCamera.CoordinateFrame.p
		local partDist = Utility.distanceVector3(colLocation, cameraPos)
		local planeDist = Utility.distanceVector3(colPoint, cameraPos)

		if FuzzyMath.fuzzyCompareVector3(currentRay.Direction.Unit, (cameraPos - colPoint).Unit) then
			planeDist = 800
		end

		if planeDist < 2 then
			planeDist = 800
		end

		if planeDist > 500 then
			if partDist > 500 then
				colPoint = cameraPos + (currentRay.Direction.Unit *30)
			end
		end

	end

	local previousPoint = Vector3.new(0,0,0)

	if selectedPart then
		previousPoint = selectedPart.Position
	else
		local filteredSelection= Selection.getFilteredSelection()
		if not filteredSelection or #filteredSelection == 0 then
			return
		end
		selectedPart = Metapart.convertToPart(filteredSelection[1])
	end

	if not startLocation then return end

	if not hasStartedDragging then
		analyticsRecordFreeformDragBegin()
		hasStartedDragging = true
	end
	analyticsRecordFreeformDragUpdate(colPoint)

	movePart(colPoint - startLocation, plugin.CollisionEnabled)
	lastDist = lastDist + (selectedPart.Position - previousPoint)

	updateInvisiblePart()
end

function selectDragPlane(selectBase)
	local ray = nil

	--if we are over plane, return early
	if Adorn.isOverPlaneSelect() then
		Adorn.setPlaneSelectingMode(false)
		return
	end

	ray = mouse.UnitRay
	ray = Ray.new(ray.Origin, ray.Direction* 800)

	--TODO: add tmpNormal
	local tmpPart, tmpNormal, tmpLocation

	if selectBase then
		tmpPart = Instance.new("Part", cg)
		tmpPart.Size = Vector3.new(100, 1, 100)
		tmpPart.CFrame = CFrame.new(0, -0.5, 0)
		tmpLocation = Vector3.new(0,0,0)
		tmpNormal = Vector3.new(0, 1, 0)
	else
		tmpPart = game.Workspace:FindPartOnRay(ray)
	end

	if not tmpPart then
		Adorn.setPlaneSelectingMode(false)
		return
	end

	if not selectBase then
		tmpLocation = rayBoxIntersection(ray, tmpPart.CFrame, tmpPart.Size)
	end

	if secondaryPart then
		secondaryPart:Destroy()
	end

	secondaryPart = tmpPart
	secondaryLocation = tmpLocation

	--use proxy part
	local tmpPart = Instance.new("Part", cg)
	tmpPart.Size = secondaryPart.Size
	tmpPart.CFrame = secondaryPart.CFrame

	secondaryPart = tmpPart

	secondaryPartCFrame = secondaryPart.CFrame:toWorldSpace(CFrame.new(secondaryPart.Size / 2))
	secondaryPartSideSelected = nil

	local localLocation = nil
	local halfSize = nil

	if secondaryPart and secondaryLocation then

		localLocation = secondaryPart.CFrame:pointToObjectSpace(secondaryLocation)

		local v0, v1, v2 = nil
		-- below aren't locals, and they're not meant to be
		w0, w1, w2, w3 = nil -- global variables

		halfSize = secondaryPart.Size /2

		if FuzzyMath.fuzzyCompare(math.abs(localLocation.X), halfSize.X) then
			v0 = localLocation + Vector3.new(0,0,1)
			v1 = localLocation + Vector3.new(0,1,1)
			v2 = localLocation + Vector3.new(0,1,0)

			w0 = Vector3.new(localLocation.X,0,0) + Vector3.new(0,-1,1) * halfSize
			w1 = Vector3.new(localLocation.X,0,0) + Vector3.new(0,1,1) * halfSize
			w2 = Vector3.new(localLocation.X,0,0) + Vector3.new(0,-1,-1) * halfSize
			w3 = Vector3.new(localLocation.X,0,0) + Vector3.new(0,1,-1) * halfSize

			--secondaryPart.CFrame = secondaryPart.CFrame * CFrame.Angles(0, 0, math.rad(90))

			if FuzzyMath.fuzzyCompare(localLocation.X, halfSize.X) then
				secondaryPartSideSelected = RIGHT_SIDE
			else
				secondaryPartSideSelected = LEFT_SIDE
			end

		elseif FuzzyMath.fuzzyCompare(math.abs(localLocation.Y), halfSize.Y) then
			v0 = localLocation + Vector3.new(0,0,1)
			v1 = localLocation + Vector3.new(1,0,1)
			v2 = localLocation + Vector3.new(1,0,0)

			w0 = Vector3.new(0,localLocation.Y,0) + Vector3.new(-1,0,1) * halfSize
			w1 = Vector3.new(0,localLocation.Y,0) + Vector3.new(1,0,1) * halfSize
			w2 = Vector3.new(0,localLocation.Y,0) + Vector3.new(-1,0,-1) * halfSize
			w3 = Vector3.new(0,localLocation.Y,0) + Vector3.new(1,0,-1) * halfSize

			if FuzzyMath.fuzzyCompare(localLocation.Y, halfSize.Y) then
				secondaryPartSideSelected = TOP_SIDE
			else
				secondaryPartSideSelected = BOTTOM_SIDE
			end

		elseif FuzzyMath.fuzzyCompare(math.abs(localLocation.Z), halfSize.Z) then
			v0 = localLocation + Vector3.new(0,1,0)
			v1 = localLocation + Vector3.new(1,1,0)
			v2 = localLocation + Vector3.new(1,0,0)

			w0 = Vector3.new(0,0,localLocation.Z) + Vector3.new(-1,1,0) * halfSize
			w1 = Vector3.new(0,0,localLocation.Z) + Vector3.new(1,1,0) * halfSize
			w2 = Vector3.new(0,0,localLocation.Z) + Vector3.new(-1,-1,0) * halfSize
			w3 = Vector3.new(0,0,localLocation.Z) + Vector3.new(1,-1,0) * halfSize

			--secondaryPart.CFrame = secondaryPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)

			if FuzzyMath.fuzzyCompare(localLocation.Z, halfSize.Z) then
				secondaryPartSideSelected = BACK_SIDE
			else
				secondaryPartSideSelected = FRONT_SIDE
			end
		end

		if v0 and v1 and v2 then
			pV0 = v0
			pV1 = v1
			pV2 = v2

			v0 = secondaryPart.CFrame:pointToWorldSpace(v0)
			v1 = secondaryPart.CFrame:pointToWorldSpace(v1)
			v2 = secondaryPart.CFrame:pointToWorldSpace(v2)

			baseDragPlane = createPlane(v0, v1, v2)
			dragPlane = nil
		end
	end

	local pointLocation = localLocation / Utility.absVector3(localLocation) * -1
	pointLocation = Utility.cleanVector3(pointLocation)

	workplaneFrame = secondaryPart.CFrame - (secondaryPart.CFrame:pointToWorldSpace(halfSize * pointLocation) - secondaryPart.CFrame.p)

	if secondaryPartSideSelected == LEFT_SIDE or secondaryPartSideSelected == RIGHT_SIDE then
		workplaneFrame = workplaneFrame * CFrame.Angles(0, 0, math.rad(90))
	elseif secondaryPartSideSelected == BACK_SIDE or secondaryPartSideSelected == FRONT_SIDE then
		workplaneFrame = workplaneFrame * CFrame.Angles(math.rad(90), 0, 0)
	end

	updateInvisiblePart()
	--workplaneFrame = invisiblePart.CFrame - invisiblePart.CFrame.p + workplaneFrame.p


	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
	if filteredSelectionMetapart then
		filteredSelectionMetapart.UpdatePlaneCFrame = workplaneFrame
	end

	Adorn.setPlaneSelectingMode(false)
end

function removeDragPart()
	local selection = {}
	local dragPartFound = false
	local currentSelection = game:GetService("Selection"):Get()
	for i, v in ipairs(currentSelection) do
		if v.Parent ~= cg and v.Name ~= "DragParte1b1aec5" and v.Name ~= "InvisibleParte1b1aec5" then
			table.insert(selection, v)
		else
			v.Parent = game:GetService("CoreGui")
			dragPartFound = true
		end
	end

	if dragPartFound then
		setSelection(selection)
	end
end

function releasePart()

	--local initialTick = tick()
	firstMove = true
	rotationalDiff = 0

	if setAnchoredStateForMovingParts then -- while running
		local selection = getCurrentSelectionWithChildren()
		setAnchoredStateForMovingParts = false
		for i, v in ipairs(selection) do
			v.Anchored = states[i]
		end
		states = {}
	end

	RubberBand.finishRubberbandDrag()

	recreateAdornment() -- add inside of finishRubberbandDrag?


	setWaypoint()
	if freeDragging then
		if #game.Selection:Get() == 1 and game.Selection:Get()[1]:IsA("BasePart") then
			Adorn.setAllAdornVisibility(true)
		end
		lastDist = Vector3.new(0,0,0)
		selectedPartCFrameBeforeDrag = nil
		if partMoved then
			JoinSelection()
		end
	elseif handleWasDragged then
		JoinSelection()
	end

	partMoved = false

	dragFromToolbox = false

	handleWasDragged = false
	freeDragging = false

	originalDragPartOrientation = nil

	if dragPart then
		dragPartHoloBox.Visible = false
		dragPart.Parent = nil

		dragPartHoloBox.Adornee = dragPart
		dragPartHoloBox.Size = dragPartHoloBox.Adornee.Size-- + Vector3.new(.01, .01, .01)
		dragPartHoloBox.AlwaysOnTop = true
		dragPartHoloBox.CFrame = dragPart.CFrame - dragPart.CFrame.p
		--dragPartHoloBox.Visible = true
	end

	if planeDragging and Adorn.isPlaneSelectingModeOn() then
		selectDragPlane()
		planeDragging = false
	end

	if holoBox then
		holoBox:Destroy()
		holoBox = nil
	end
	if planeObject then
		planeObject:Destroy()
		planeObject = nil
	end

	startLocation = nil

end

function grabHandle(handle, position)

	if not position then return end
	originalPosition = position
	currentDist = Vector3.new(0,0,0)

	if handle ~= R_XY and
		handle ~= R_XZ and
		handle ~= R_YZ and
		handle ~= H_PLANE then
		updateDragPart()
	end

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
	if not filteredSelectionMetapart then return end

	originalCFrame = filteredSelectionMetapart.CFrame
	originalSize = filteredSelectionMetapart.Size

	previousAABBCFrame = invisiblePart.CFrame

	mouseOffsetOnGrabHandle = nil --will be set in preUpdatePart

	preUpdatePart()
end

function releaseHandle()

	itemToUpdate = nil
	rotationalDiff = 0

	local handle = Adorn.getCurrentHandle()

	if (handle == H_NONE) then return end

	if handle ~= H_PLANE then
		analyticsSendHandleDragged(HandleNames[handle])
	end

	JoinSelection()

	originalPosition = nil
	currentDist = nil
	originalSize = nil
	originalCFrame = nil
	previousAABBCFrame = nil
end

function recreateAdornment()
	if not adornmentUpdateNeeded then return end
	adornmentUpdateNeeded = false

	if not invisiblePart then
		invisiblePart = Instance.new("Part", nil)
		invisiblePart.Name = "InvisibleParte1b1aec5"
		invisiblePart.TopSurface = Enum.SurfaceType.Smooth
		invisiblePart.BottomSurface = Enum.SurfaceType.Smooth
		invisiblePart.Archivable = false
		invisiblePart.Transparency = 1
	end

	if not castPart then
		castPart = Instance.new("Part")
	end

	Adorn.adornInstanceWithTranslate(invisiblePart)
	Adorn.adornInstanceWithPlane(invisiblePart)

	local selection = Selection.getFilteredSelection()

	if (#selection > 0) then
		Adorn.setPlaneVisibility(true)
		if (#selection == 1) and selection[1]:IsA("BasePart") then--and game.Selection:Get()[1]:IsA("BasePart") then
			Adorn.adornInstanceWithScale(selection[1])
		else
			Adorn.setScaleAdornVisibility(false)
		end
	end

	updateRotatePart()
	updateInvisiblePart()
end

function isInSelection(part)
	if not part then return nil end

	local selection = game.Selection:Get()

	for _,p in ipairs(selection) do
		if p == part then return true end
	end
	return false
end

function getHighestModelParent(instance)
	-- If instance or any ancestor is a Model,
	-- return the highest Model in the ancestor hierarchy.
	-- Otherwise return nil.
	if not instance then
		return nil
	end

	if (instance == game.Workspace) then
		return nil
	end

	-- Is there a model above me?  Use that.
	local bestResult = getHighestModelParent(instance.Parent)
	if (bestResult ~= nil) then
		return bestResult
	end

	-- Am I a Model?
	if instance:IsA("Model") then
		return instance
	end

	-- I got nothing.
	return nil
end

function getPVInstanceForPart(instance)
	-- If this instance or any ancestor is a Model, return the highest
	-- Model in the heirarchy.
	-- Otherwise return this model iff it's a non-Workspace PVInstance.
	local result = getHighestModelParent(instance)
	if (result ~= nil) then
		return result
	end

	if instance:IsA("PVInstance") and not instance:IsA("Workspace") then
		return instance
	else
		return nil
	end
end

function getTopPVInstance(instance)
	if not instance then
		return nil
	end

	if (instance.Parent == game.Workspace) then
		if instance:IsA("PVInstance") and not instance:IsA("Workspace") then
			return instance
		end
		return nil
	end

	local returnInstance = getTopPVInstance(instance.Parent)

	if not returnInstance then
		if instance:IsA("PVInstance") and not instance:IsA("Workspace") then
			return instance
		end
		return nil
	end
	return returnInstance
end

function findPartInstance(instances)
	for _,v in ipairs(instances) do
		if v:IsA("BasePart") then
			return v
		end
	end

	for _,v in ipairs(instances) do
		local tmpPart = findPartInstance(v:GetChildren())
		if tmpPart then
			return tmpPart
		end
	end

	return nil
end

function isAncestorSelected(part)
	if not part.Parent then return nil end

	if List.itemExistsInList(part.Parent, game.Selection:Get()) then
		return part.Parent
	end

	return isAncestorSelected(part.Parent)
end

function selectPart(instances)
	if currentlyOverHandle then return end

	castPlane = nil
	local ray = mouse.UnitRay
	ray = Ray.new(ray.Origin, ray.Direction * 800)

	local part, location = game.Workspace:FindPartOnRay(ray)

	local alreadySelected = false
	if List.itemExistsInList(part, game.Selection:Get()) then
		alreadySelected = true
	end

	if instances then
		local tmpPart = findPartInstance(instances)
		location = tmpPart.CFrame.p

		if tmpPart then
			part = tmpPart
		end

		if location.y < 0 then
			location = location * Vector3.new(1, 0, 1)
		end
	end

	if part and part.Locked and not dragFromToolbox then
		part = nil
	end

	if part and not uis:IsKeyDown(Enum.KeyCode.LeftAlt) and not alreadySelected then
		local ancestor = isAncestorSelected(part)

		if ancestor then
			part = ancestor
		else
            part = getPVInstanceForPart(part)
		end

	end

	local didChangeSelection = false
	if part then

		if not isInSelection(part) then
			if uis:IsKeyDown(Enum.KeyCode.LeftControl) then
				local selection = game.Selection:Get()
				table.insert(selection, part)
				setSelection(selection)
			else
				setSelection({part})
			end
			didChangeSelection = true

		elseif uis:IsKeyDown(Enum.KeyCode.LeftControl) then

			local selection = {}
			for _,p in ipairs(game.Selection:Get()) do
				if not(p == part) then
					table.insert(selection, p)
				end
			end

			setSelection(selection)
			didChangeSelection = true
		end

		startLocation = location

		if pV0 and pV1 and pV2 then
			part = Metapart.convertToPart(part)
			local localLocation = secondaryPart.CFrame:pointToObjectSpace(secondaryLocation)
			local partDist = secondaryPart.CFrame:pointToObjectSpace(location) - localLocation
			local v0local = pV0 + partDist
			local v1local = pV1 + partDist
			local v2local = pV2 + partDist

			v0local = secondaryPart.CFrame:pointToWorldSpace(v0local)
			v1local = secondaryPart.CFrame:pointToWorldSpace(v1local)
			v2local = secondaryPart.CFrame:pointToWorldSpace(v2local)

			dragPlane = createPlane(v0local, v1local, v2local)

			local selectedPartRotation = part.CFrame - part.CFrame.p + startLocation
			local secondaryPartRotation = secondaryPart.CFrame - secondaryPart.CFrame.p
			local newRotation = CFrame.new(selectedPartRotation.p) * secondaryPartRotation
			if uis:IsKeyDown(Enum.KeyCode.LeftShift) then
				adornmentUpdateNeeded = true
				local partGroup = Selection.getFilteredSelectionMetapart()
				partGroup.CFrame = newRotation:toWorldSpace(selectedPartRotation:toObjectSpace(partGroup.CFrame))
			end
		end
		grabPart()

	else
		RubberBand.startRubberbandDrag(Vector2.new(mouse.X, mouse.Y))
		if #game.Selection:Get() > 0 then
			-- Changed because the current seleciton will be cleared
			didChangeSelection = true
		end
	end

	analyticsSendClick(part, didChangeSelection)

	recreateAdornment()

end


function waypointChanged()
	removeDragPart()
	if not on then return end
	resetDragger()
	--updateSelection()
	updateRotatePart(Selection.getFilteredSelection())
	updateInvisiblePart()
end

function selectionChanged()
	adornmentUpdateNeeded = true
	Selection.updateSelection()
	resetDragger()

	if RubberBand.isRubberBandDragInProgress() then return end --dont update anything if still rubber band dragging

	local currentSelection = Selection.getCurrentSelection()

	local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()

	if (#currentSelection == 0 and dragFromToolbox) then
		dragFromToolbox = false
		releasePart()
	end

	if dragPart then
		dragPart.Parent = nil
	end

	if filteredSelectionMetapart then
		originalSize = filteredSelectionMetapart.Size
		originalCFrame = filteredSelectionMetapart.CFrame
	end

	if (#currentSelection == 1) then
		selectedPart = Metapart.convertToPart(currentSelection[1])
	end

	recreateAdornment()
	--updateInvisiblePart()

	if not EngineFeatureModelPivotApi then
		for i,v in ipairs(currentSelection) do
			if v:IsA("BasePart") then
				if shouldBreakJoints then
				end
			elseif v:IsA("Model") and not v:IsA("Workspace") then
				Metapart.forcePrimaryPart(v)
			end
		end
	end
end

function onDragEnter(instances)
	-- In addition to the expected DragEnter events, the engine sends us
	-- spurious empty DragEnter events which we have to ignore.
	if #instances == 0 then
		return
	end

	dragFromToolbox = true

	if not Input.getButtonState(Input.Enum.Key.MOUSE_BUTTON1) then
		Input.setButtonState(Input.Enum.Key.MOUSE_BUTTON1, true)
		selectPart(instances)
	end
end


local function togglePlaneSelection()
	if Adorn.isPlaneSelectingModeOn() then
		Adorn.setPlaneSelectingMode(false)
		planeDragging = false
		holoBox.Visible = false
		Adorn.clearExtraAdorns()
	else
		Adorn.setPlaneSelectingMode(true)
		planeDragging = true

		if not planeObject then
			planeObject = Instance.new("Part", cg)
			planeObject.Size = Vector3.new(50, 50, 0.01)
			planeObject.Position = Vector3.new(0,0,0)
			planeObject.Transparency = 1
		end

		if not holoBox then
			holoBox = Instance.new("BoxHandleAdornment", cg)
			holoBox.Visible = false
			holoBox.Adornee = planeObject
			holoBox.Size = holoBox.Adornee.Size
			holoBox.Transparency = 0.6
			holoBox.Color3 = Color3.new(38.0 / 255.0, 136.0 / 255.0, 240.0 / 255.0)
		end
	end
end

function keyPress(evt, processed)
	if processed then return end

	if evt.UserInputType == Enum.UserInputType.Keyboard then
		if (evt.UserInputState == Enum.UserInputState.Begin) then

			if on and evt.KeyCode == Enum.KeyCode.Space then
				togglePlaneSelection()
			end
			if evt.KeyCode == Enum.KeyCode.Five and (uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)) then
				if not on then On() else Off() end
			end
		end

	elseif on and evt.UserInputType == Enum.UserInputType.MouseButton1 then
		if (evt.UserInputState == Enum.UserInputState.Begin) then
			Input.setButtonState(Input.Enum.Key.MOUSE_BUTTON1, true)
			onPressMouse()
		elseif (evt.UserInputState == Enum.UserInputState.End) then
			Input.setButtonState(Input.Enum.Key.MOUSE_BUTTON1, Input.Enum.State.UP)
			onReleaseMouse()
		end
	end
end

function inputChanged(evt)

	if (Input.getButtonState(Input.Enum.Key.MOUSE_BUTTON1) and
		evt.UserInputType == Enum.UserInputType.MouseMovement) or
		(Adorn.isPlaneSelectingModeOn() and Adorn.getCurrentHandle() == H_PLANE) then

		if not originalCFrame then
			local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
			if filteredSelectionMetapart then
				originalCFrame = filteredSelectionMetapart.CFrame
			end
		end

		if not originalSize then
			local filteredSelectionMetapart = Selection.getFilteredSelectionMetapart()
			if filteredSelectionMetapart then
				originalSize = filteredSelectionMetapart.Size
			end
		end

		if originalCFrame then
			updatePart()
		end
	end
	freeDrag()
end

--------------------------------------------------

local updateAdornmentPositions = Adorn.updateAdornmentPositions

function Off()
	if not on then return end
	on = false

	plugin:Invoke("setActive", "false")

	waypointUndoConnection:disconnect()
	waypointRedoConnection:disconnect()
	--inputBeganConnection:disconnect()
	inputEndedConnection:disconnect()
	inputChangedConnection:disconnect()

	selectionChangedConnection:disconnect()

	renderSteppedConnection:disconnect()

	dragEnterConnection:disconnect()

	Adorn.destroyAdorns()

	analyticsSendSession()
end

function On()
	if on then return end

	plugin:Activate(true)
	plugin:Invoke("setActive", "true")
	on = true

	if rotateAdornPart then
		rotateAdornPart:Destroy()
		rotateAdornPart = nil
	end

	Adorn.initializeAdorns()

	waypointUndoConnection = game:GetService("ChangeHistoryService").OnUndo:connect(waypointChanged)
	waypointRedoConnection = game:GetService("ChangeHistoryService").OnRedo:connect(waypointChanged)


	inputEndedConnection = uis.InputEnded:connect(keyPress)
	inputChangedConnection = uis.InputChanged:connect(inputChanged)

	selectionChangedConnection = game:GetService("Selection").SelectionChanged:connect(selectionChanged)

	renderSteppedConnection = game:GetService("RunService").RenderStepped:connect(function()
		if Selection.getFilteredSelectionMetapart() then
			if Selection.getFilteredSelectionMetapart().IsUpdateRequired then
				spawn(function() updateAdornments() end)
			end
		end
		updateAdornmentPositions()
	end)

	dragEnterConnection = plugin:GetMouse().DragEnter:connect(onDragEnter)

	adornmentUpdateNeeded = true
	recreateAdornment()

	if not initializedDragPlane then
		selectDragPlane(true)
	end
	initializedDragPlane = true

	selectionChanged()

	analyticsSessionBegin()
end

loaded = true

inputBeganConnection = uis.InputBegan:connect(keyPress)
