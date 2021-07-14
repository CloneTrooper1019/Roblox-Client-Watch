return function(draggerContext)
	local Plugin = script.Parent.Parent.Parent.Parent
	local Constants = require(Plugin.Src.Util.Constants)
	local ToolUtil = require(Plugin.Src.Util.ToolUtil)

	local Workspace = game.Workspace

	local dragCandidates = {}

	if ToolUtil:isDraggerPointMode(draggerContext) then
		local verts = Workspace:FindFirstChild("RbfPoints")
		for _, object in ipairs(verts:GetDescendants()) do
			if object:FindFirstChild(Constants.LCE_POINT_TAG) then
				table.insert(dragCandidates, {
					Center = object.CFrame.p,
					Selectable = {
						Deformer = object.Parent.Name,
						Index = tonumber(object.Name),
					}
				})
			end
		end
	elseif ToolUtil:isDraggerLatticeMode(draggerContext) then
		local controlPoints = Workspace:FindFirstChild("Lattices")
		for _, object in ipairs(controlPoints:GetDescendants()) do
			local latticePoint = object:FindFirstChild(Constants.LCE_CONTROL_TAG)
			if latticePoint then
				table.insert(dragCandidates, {
					Center = object.CFrame.p,
					Selectable = {
						Deformer = object.Parent.Name,
						ID = object.Name,
						GridPosition = latticePoint.Value,
					}
				})
			end
		end
	end

	return dragCandidates
end