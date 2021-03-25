local Workspace = game:GetService("Workspace")
local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local getSelectableWithCache = require(Plugin.Packages.DraggerSchemaCore.getSelectableWithCache)

local setWorldPivot = require(Plugin.Src.Utility.setWorldPivot)
local computeSnapPointsForInstance = require(Plugin.Src.Utility.computeSnapPointsForInstance)
local SnapPoints = require(Plugin.Src.Components.SnapPoints)
local DraggedPivot = require(Plugin.Src.Components.DraggedPivot)

local SMALL_REGION_RADIUS = Vector3.new(0.1, 0.1, 0.1)

local MoveHandlesImplementation = {}
MoveHandlesImplementation.__index = MoveHandlesImplementation

function MoveHandlesImplementation.new(draggerContext)
	return setmetatable({
		_draggerContext = draggerContext,
	}, MoveHandlesImplementation)
end

function MoveHandlesImplementation:_selectedIsActive()
	if self._draggerContext:shouldShowActiveInstanceHighlight() then
		return self._selection[#self._selection] == self._primaryObject
	else
		return false
	end
end

function MoveHandlesImplementation:_setCurrentSnap(object)
	self._snapPoints = computeSnapPointsForInstance(object)
	self._snapPointsAreFor = object
end

function MoveHandlesImplementation:beginDrag(selection, initialSelectionInfo)
	self._selection = selection
	self._initialPivot = initialSelectionInfo:getBoundingBox()
	self._primaryObject = initialSelectionInfo:getPrimaryObject()
	self:_setCurrentSnap(self._primaryObject)
end

local function getSmallRegionAround(cframe)
	return Region3.new(cframe.Position - SMALL_REGION_RADIUS, cframe.Position + SMALL_REGION_RADIUS)
end

function MoveHandlesImplementation:_findNewSnapTargetViaCollision(pivot)
	local region = getSmallRegionAround(pivot)
	local hitParts = Workspace:FindPartsInRegion3WithWhiteList(region, {self._snapPointsAreFor})
	if #hitParts > 0 then
		-- Still colliding with something inside of the thing we last got snap
		-- points for, no reason to change.
		return
	end

	hitParts = Workspace:FindPartsInRegion3(region, self._snapPointsAreFor)
	for _, hitPart in ipairs(hitParts) do
		local selectable = getSelectableWithCache(hitPart, false, {})
		if selectable then
			self:_setCurrentSnap(selectable)
			return
		end
	end
end

function MoveHandlesImplementation:updateDrag(globalTransform)
	local newPivot = globalTransform * self._initialPivot
	setWorldPivot(self._primaryObject, newPivot)
	self:_findNewSnapTargetViaCollision(newPivot)
	return globalTransform
end

function MoveHandlesImplementation:endDrag()

end

function MoveHandlesImplementation:getSnapPoints()
	if self._draggerContext:shouldSnapPivotToGeometry() then
		return self._snapPoints
	else
		return nil
	end
end

function MoveHandlesImplementation:render(currentBasisCFrame)
	local contents = {
		DraggedPivot = Roact.createElement(DraggedPivot, {
			DraggerContext = self._draggerContext,
			CFrame = currentBasisCFrame,
			IsActive = self:_selectedIsActive(),
		}),
	}
	if self._draggerContext:shouldSnapPivotToGeometry() then
		contents.SnapPoints = Roact.createElement(SnapPoints, {
			SnapPoints = self._snapPoints,
			DraggerContext = self._draggerContext,
		})
	end
	return Roact.createFragment(contents)
end

return MoveHandlesImplementation