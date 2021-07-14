--[[
	DraggerContext is a class which wraps all of the global state which the
	dragger needs to access to operate. This is the plugin implementation of the
	context, which pulls those globals from the studio session's services, to
	be used by a plugin.
]]

local DraggerFramework = script.Parent.Parent

local Analytics = require(DraggerFramework.Utility.Analytics)
local setInsertPoint = require(DraggerFramework.Utility.setInsertPoint)

local FallbackLocalizationTable = DraggerFramework.Resources.TranslationDevelopmentTable
local TranslatedLocalizationTable = DraggerFramework.Resources.TranslationReferenceTable

local getFFlagSummonPivot = require(DraggerFramework.Flags.getFFlagSummonPivot)

local DraggerContext = {}
DraggerContext.__index = DraggerContext

local RAYCAST_DIRECTION_SCALE = 10000
local HANDLE_SCALE_FACTOR = 0.05
local FALLBACK_LOCALE = "en_US"

function DraggerContext.new(plugin, editDataModel, userSettings, selection)
	return setmetatable({
		_editDataModel = editDataModel,
		_plugin = plugin,
		_userSettings = userSettings,
		_studioService = editDataModel:GetService("StudioService"),
		_draggerService = getFFlagSummonPivot() and editDataModel:GetService("DraggerService") or nil,
		_runService = editDataModel:GetService("RunService"),
		_studioSettings = userSettings.Studio,
		_workspace = editDataModel:GetService("Workspace"),
		_userInputService = editDataModel:GetService("UserInputService"),
		_changeHistoryService = editDataModel:GetService("ChangeHistoryService"),
		_mouse = plugin:GetMouse(),
		_selection = selection,
		LocaleChangedSignal = editDataModel:GetService("StudioService"):GetPropertyChangedSignal("StudioLocaleId"),
		_fallbackTranslators = {},
		_translators = {},
	}, DraggerContext)
end

-- What instance should the plugin's GUI objects get created under?
function DraggerContext:getGuiParent()
	return self._editDataModel:GetService("CoreGui")
end

function DraggerContext:setHoverInstance(instance)
	self._studioService.HoverInstance = instance
end

function DraggerContext:shouldUseLocalSpace()
	return self._studioService.UseLocalSpace
end

function DraggerContext:areCollisionsEnabled()
	return self._plugin.CollisionEnabled
end

function DraggerContext:areConstraintsEnabled()
	return self._studioService.DraggerSolveConstraints
end

function DraggerContext:areConstraintDetailsShown()
	return self._studioService.ShowConstraintDetails
end

function DraggerContext:shouldDrawConstraintsOnTop()
	return self._studioService.DrawConstraintsOnTop
end

function DraggerContext:shouldJoinSurfaces()
	return self._plugin:GetJoinMode() ~= Enum.JointCreationMode.None
end

function DraggerContext:shouldShowHover()
	return self._studioSettings["Show Hover Over"]
end

function DraggerContext:shouldAnimateHover()
	return self._studioSettings["Animate Hover Over"]
end

function DraggerContext:shouldSelectScopeByDefault()
	return self._studioSettings["Physical Draggers Select Scope By Default"]
end

function DraggerContext:getHoverAnimationSpeedInSeconds()
	local speed = self._studioSettings["Hover Animate Speed"]
	if speed == Enum.HoverAnimateSpeed.VerySlow then
		return 2
	elseif speed == Enum.HoverAnimateSpeed.Slow then
		return 1
	elseif speed == Enum.HoverAnimateSpeed.Medium then
		return 0.5
	elseif speed == Enum.HoverAnimateSpeed.Fast then
		return 0.25
	elseif speed == Enum.HoverAnimateSpeed.VeryFast then
		return 0.1
	end
	return 0
end

function DraggerContext:getHoverBoxColor(isActive)
	if isActive then
		return self._studioSettings["Active Hover Over Color"]
	else
		return self._studioSettings["Hover Over Color"]
	end
end

function DraggerContext:getHoverLineThickness()
	if getFFlagSummonPivot() then
		return self._draggerService.HoverThickness
	else
		return 0.04
	end
end

function DraggerContext:getSelectionBoxColor(isActive)
	if isActive then
		return self._studioSettings["Active Color"]
	else
		return self._studioSettings["Select Color"]
	end
end

function DraggerContext:getGeometrySnapColor()
	return self._draggerService.GeometrySnapColor
end

function DraggerContext:getCameraCFrame()
	return self._workspace.CurrentCamera.CFrame
end

function DraggerContext:getMouseUnitRay()
	return self._mouse.UnitRay
end

function DraggerContext:getHandleScale(focusPoint)
	local distance = (self:getCameraCFrame().Position - focusPoint).Magnitude
	local angleFrac = math.sin(math.rad(self._workspace.CurrentCamera.FieldOfView))
	return angleFrac * distance * HANDLE_SCALE_FACTOR
end

function DraggerContext:getMouseRay()
	local unitRay = self:getMouseUnitRay()
	return Ray.new(unitRay.Origin, unitRay.Direction * RAYCAST_DIRECTION_SCALE)
end

function DraggerContext:getMouseLocation()
	return self._userInputService:GetMouseLocation()
end

function DraggerContext:viewportPointToRay(mouseLocation)
	return self._workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
end

function DraggerContext:worldToViewportPoint(worldPoint)
	return self._workspace.CurrentCamera:WorldToViewportPoint(worldPoint)
end

function DraggerContext:getViewportSize()
	return self._workspace.CurrentCamera.ViewportSize
end

function DraggerContext:setMouseIcon(icon)
	self._mouse.Icon = icon
end

function DraggerContext:getSelection()
	return self._selection
end

-- Are non-anchored parts in the world currently being physically simulated?
-- (i.e. are they moving around of thier own accord)
function DraggerContext:isSimulating()
	return self._runService:IsRunning()
end

function DraggerContext:isAltKeyDown()
	return self._userInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or
		self._userInputService:IsKeyDown(Enum.KeyCode.RightAlt)
end

function DraggerContext:isCtrlKeyDown()
	return self._userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
		self._userInputService:IsKeyDown(Enum.KeyCode.RightControl)
end

function DraggerContext:isShiftKeyDown()
	return self._userInputService:IsKeyDown(Enum.KeyCode.LeftShift) or
		self._userInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

function DraggerContext:shouldExtendSelection()
	return self:isCtrlKeyDown() or self:isShiftKeyDown()
end

function DraggerContext:getGridSize()
	return self._studioService.GridSize
end

-- Wrapped in a function because of the awkward situation where there's no
-- explicit way to determine whether grid snapping is on or off right now, and
-- the implementation of this may change once there is.
-- Currently DISABLED_GRID_SIZE is what StudioService returns when grid snapping
-- is disabled, so detect based on that.
local DISABLED_GRID_SIZE = 0.01
function DraggerContext:snapToGridSize(distance)
	local gridSize = self._studioService.GridSize
	if math.abs(gridSize - DISABLED_GRID_SIZE) < 0.001 then
		return distance
	else
		return math.floor(distance / gridSize + 0.5) * gridSize
	end
end

function DraggerContext:getRotateIncrement()
	return self._studioService.RotateIncrement
end

function DraggerContext:getAnalytics()
	return Analytics
end

function DraggerContext:gizmoRaycast(origin, direction, raycastParams)
	return self._studioService:GizmoRaycast(origin, direction, raycastParams)
end

function DraggerContext:setInsertPoint(location)
	setInsertPoint(location)
end

function DraggerContext:shouldShowActiveInstanceHighlight()
	return self._studioService.ShowActiveInstanceHighlight
end

function DraggerContext:shouldAlignDraggedObjects()
	return self._studioService.AlignDraggedObjects
end

function DraggerContext:addUndoWaypoint(waypointIdentifier, waypointText)
	-- Nothing to do with waypoint text currently, but we will need to do
	-- something with localizing undo waypoints eventually.
	self._changeHistoryService:SetWaypoint(waypointIdentifier)
end

-- TODO mlangen: Share this code with DevFramework somehow. We don't want to
-- include the entirety of DevFramework just to translate a couple of strings,
-- but we do really want to share just the localization part of DevFramework.
-- For now, this code does mostly the same thing as DevFramework's Localization
-- class.
function DraggerContext:getText(scope, key, args)
	key = ("Studio.DraggerFramework.%s.%s"):format(scope, key)
	local locale = self._studioService.StudioLocaleId
	if locale == FALLBACK_LOCALE then
		local fallbackTranslator = self._fallbackTranslators[locale]
		if not fallbackTranslator then
			fallbackTranslator = FallbackLocalizationTable:GetTranslator(FALLBACK_LOCALE)
			self._fallbackTranslators[locale] = fallbackTranslator
		end
		return fallbackTranslator:FormatByKey(key, args)
	else
		local referenceTranslator = self._translators[locale]
		if not referenceTranslator then
			referenceTranslator = TranslatedLocalizationTable:GetTranslator(locale)
			self._translators[locale] = referenceTranslator
		end
		local success, result = pcall(function()
			return referenceTranslator:FormatByKey(key, args)
		end)
		if success then
			return result
		else
			local fallbackTranslator = self._fallbackTranslators[locale]
			if not fallbackTranslator then
				fallbackTranslator = FallbackLocalizationTable:GetTranslator(FALLBACK_LOCALE)
				self._fallbackTranslators[locale] = fallbackTranslator
			end
			return fallbackTranslator:FormatByKey(key, args)
		end
	end
end

-- Takes a StudioStyleGuideColor enum
function DraggerContext:getThemeColor(item)
	return self._studioSettings.Theme:GetColor(item)
end

function DraggerContext:getSetting(name)
	return self._plugin:GetSetting(name)
end

function DraggerContext:setSetting(name, value)
	self._plugin:SetSetting(name, value)
end

function DraggerContext:setPivotIndicator(state)
	local oldValue = self._draggerService.ShowPivotIndicator
	self._draggerService.ShowPivotIndicator = state
	return oldValue
end

return DraggerContext