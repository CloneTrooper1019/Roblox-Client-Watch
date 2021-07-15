local DraggerFramework = script.Parent.Parent
local Math = require(DraggerFramework.Utility.Math)

--[[
	Returns the distance the mouse cursor was dragged from dragStartPosition
    along dragDirection

	This is non-trivial when the cursor gets away from the axis on the screen.
	Let p be the start of the handle, u be the direction of the handle, and eye
	be the origin of the mouse ray (eye of the camera).

	Let v be the unit vector from p pointing to the eye, and let w = v x u.

	Then v is normal to plane defined by points eye, p and the vector u.
	|v| = 0 if and only if the handle projects to a dot on the screen.

	Let cur be where the mouse ray intersects the plane at p spanned by u, v.
	Find the normal projection of cur onto the handle ray, and use that to
	compute the dragged distance.
]]
local function computeDraggedDistance(dragStartPosition, dragDirection, mouseRay)
    local eye = mouseRay.Origin
    local ray = mouseRay.Direction.Unit
	local handleToEyeDirection = (eye - dragStartPosition).Unit
	local eyePlaneNormal = dragDirection:Cross(handleToEyeDirection)
	-- the handle axis projects to a point, can't compute drag distance
	if eyePlaneNormal:Dot(eyePlaneNormal) < 0.0001 then
		return false
	end
	local dragPlaneNormal = (dragDirection:Cross(eyePlaneNormal)).Unit
    -- mouse ray nearly parallel to drag axis, halt drag before sending part to infinity
    if ray:Dot(dragPlaneNormal) < 0.0001 then
        return false
    end
	local cursorPosition = Math.intersectRayPlanePoint(eye, ray, dragStartPosition, dragPlaneNormal)
	local draggedDistance = (cursorPosition - dragStartPosition):Dot(dragDirection)
  	return true, draggedDistance
end

return computeDraggedDistance