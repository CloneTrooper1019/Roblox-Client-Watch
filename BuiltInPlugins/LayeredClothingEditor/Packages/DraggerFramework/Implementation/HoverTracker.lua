
local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local SelectionHelper = require(DraggerFramework.Utility.SelectionHelper)

--[[
	Ignored handle hits: When the ToolImplementation's shouldBiasTowardsObject
	function returns true, then this function will decide whether to ignore
	handle clicks where the user clicked outside of the handle's visual, but
	still within the handle's invisible hitbox.
]]
local function isIgnoredHandleHit(handles, mouseRay, selectionInfo, hitItem)
	if not handles:shouldBiasTowardsObjects() then
		-- Only potentially ignores if we're biased towards parts
		return false
	end

	if not hitItem or not selectionInfo:doesContainItem(hitItem) then
		-- Only bias towards parts when clicking on something in the selection
		return false
	end

	-- Ignore the hit if when ignoring the extra threshold the handle is no
	-- longer hit.
	local ignoreExtraThreshold = true
	return handles:hitTest(mouseRay, ignoreExtraThreshold) == nil
end

local HoverTracker = {}
HoverTracker.__index = HoverTracker

function HoverTracker.new(draggerSchema, handlesList, onHoverExternallyChangedFunction)
	assert(type(handlesList) == "table")
	assert(type(draggerSchema) == "table")
	return setmetatable({
		_draggerSchema = draggerSchema,
		_handlesList = handlesList,
		_hoverHandleId = nil,
		_hoverItem = nil,
		_onHoverChanged = onHoverExternallyChangedFunction,
	}, HoverTracker)
end

local function isCloser(distance, isOnTop, currentDistance, currentIsOnTop)
	if currentIsOnTop then -- Neat logic
		return isOnTop and distance < currentDistance
	else
		return isOnTop or distance < currentDistance
	end
end

function HoverTracker:update(draggerContext, currentSelection, selectionInfo)
	assert(currentSelection ~= nil)
	local oldHoverSelectable = self._hoverSelectable

	-- Hover parts in the workspace
	local mouseRay = draggerContext:getMouseRay()
	local hitSelectable, hitItem, distanceToHover =
		self._draggerSchema.getMouseTarget(draggerContext, mouseRay, currentSelection)
	self._hoverItem = hitItem
	self._hoverSelectable = hitSelectable
	self._hoverHandleId = nil
	if hitSelectable ~= nil then
		self._hoverDistance = distanceToHover
		self._hoverPosition = mouseRay.Origin + mouseRay.Direction.Unit * distanceToHover
	else
		distanceToHover = math.huge
		self._hoverDistance = math.huge
		self._hoverPosition = nil
	end

	self._hoverHandles = nil
	local currentIsOnTop = false
	for _, handles in pairs(self._handlesList) do
		-- Possibly hover a handle instead if we have a handle closer than the part
		-- and the hit wasn't ignored by bias towards hovering parts.
		local hoverHandleId, hoverHandleDistance, isOnTop = handles:hitTest(mouseRay, false)
		if hoverHandleId then
			if isCloser(hoverHandleDistance, isOnTop, distanceToHover, currentIsOnTop) and
				not isIgnoredHandleHit(handles, mouseRay, selectionInfo, hitItem) then
				self._hoverHandles = handles
				self._hoverHandleId = hoverHandleId
				self._hoverDistance = hoverHandleDistance
				self._hoverPosition = nil
				distanceToHover = hoverHandleDistance
				currentIsOnTop = isOnTop
			end
		end
	end

	if self._hoverHandles then
		self._draggerSchema.setHover(draggerContext, nil, nil)
	else
		self._draggerSchema.setHover(draggerContext, self._hoverSelectable, self._hoverItem)
	end

	if self._onHoverChanged and self._hoverSelectable ~= oldHoverSelectable then
		self:_freeHoverEscapeDetector()
		if self._hoverSelectable then
			self._hoverEscapeDetector =
				self._draggerSchema.HoverEscapeDetector.new(
					draggerContext, self._hoverSelectable, self._onHoverChanged)
		end
	end
end

function HoverTracker:_freeHoverEscapeDetector()
	if self._hoverEscapeDetector then
		self._hoverEscapeDetector:destroy()
		self._hoverEscapeDetector = nil
	end
end

function HoverTracker:clearHover(draggerContext)
	self:_freeHoverEscapeDetector()
	self._hoverItem = nil
	self._hoverSelectable = nil
	self._hoverPosition = nil
	self._hoverHandles = nil
	self._hoverHandleId = nil
	self._hoverDistance = nil
	self._draggerSchema.setHover(draggerContext, nil, nil)
end

--[[
	Returns: The Id of the hovered handle, the distance to that handle
]]
function HoverTracker:getHoverHandleId()
	return self._hoverHandles, self._hoverHandleId, self._hoverDistance
end

--[[
	Returns: The hovered instance, and the world position of the hit on it
]]
function HoverTracker:getHoverItem()
	return self._hoverItem, self._hoverPosition
end

function HoverTracker:getHoverSelectable()
	return self._hoverSelectable
end

return HoverTracker