-- Wrapper around WorldRoot::SetInsertPoint, since that function is Roblox only,
-- but we want the DraggerFramework to be forkable.

local Workspace = game:GetService("Workspace")

return function(insertPoint)
	pcall(function()
		Workspace:SetInsertPoint(insertPoint, true)
	end)
end