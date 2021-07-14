local Plugin = script.Parent.Parent.Parent.Parent
local Constants = require(Plugin.Src.Util.Constants)
local ToolUtil = require(Plugin.Src.Util.ToolUtil)
local Workspace = game:GetService("Workspace")

return function(draggerContext, mouseRay, currentSelection)
	local whitelist = {
		Workspace:FindFirstChild("RbfPoints"),
		Workspace:FindFirstChild("Lattices")
	}
	local hitItem, hitPosition = Workspace:FindPartOnRayWithWhitelist(mouseRay, whitelist)

	-- Selection favoring: If there is a selected object and a non-selected
	-- object almost exactly coincident underneath the mouse, then we should
	-- favor the selected one, even if due to floating point error the non
	-- selected one comes out slightly closer.
	-- Without this case, if you duplicate objects and try to drag them, you
	-- may end up dragging only one of the objects because you clicked on the
	-- old non-selected copy, as opposed to the selected one you meant to.

	if hitItem then
		local hitSelectedObject, hitSelectedPosition
			= Workspace:FindPartOnRayWithWhitelist(mouseRay, whitelist)
		if hitSelectedObject and hitSelectedPosition:FuzzyEq(hitPosition) then
			hitItem = hitSelectedObject
		end
	end

	local hitDistance = (mouseRay.Origin - hitPosition).Magnitude

	if hitItem then
		local latticeTag = hitItem:FindFirstChild(Constants.LCE_CONTROL_TAG)
		if ToolUtil:isDraggerPointMode(draggerContext) and hitItem:FindFirstChild(Constants.LCE_POINT_TAG) then
			local selectedPointMeta = draggerContext.SelectedPointMeta
			local result = {Deformer = hitItem.Parent.Name, Index = tonumber(hitItem.Name)}
			result = setmetatable(result, selectedPointMeta)
			return result, hitItem, hitDistance
		elseif ToolUtil:isDraggerLatticeMode(draggerContext) and latticeTag then
			local selectedControlPointMeta = draggerContext.SelectedControlPointMeta
			local result = {
				Deformer = hitItem.Parent.Name,
				ID = hitItem.Name,
				GridPosition = latticeTag.Value
			}
			result = setmetatable(result, selectedControlPointMeta)
			return result, hitItem, hitDistance
		end
	else
		return nil
	end
end