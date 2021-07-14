-- get transparency on lc clothes, lc avatar, or cages
local Plugin = script.Parent.Parent.Parent
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local function getTransparency(item)
	if not item then
		return 0
	end
	if item:IsA("MeshPart") then
		-- for lc clothes, get transparency of itself
		return ModelUtil.transparencyFromPropertyToLCEditor(item.Transparency)
	elseif item:IsA("Model") then
		-- for lc avatar, get transparency of the first mesh part child
		local meshPart = item:FindFirstChildWhichIsA("MeshPart")
		if meshPart then
			return ModelUtil.transparencyFromPropertyToLCEditor(meshPart.Transparency)
		end
		warn("Avatar does not have a MeshPart as child")
		return 0
	elseif item:IsA("Folder") then
		-- for lc avatar, get transparency of the first part child
		for _, v in pairs(item:GetDescendants()) do
			if v:IsA("BasePart") then
				return ModelUtil.transparencyFromPropertyToLCEditor(v.Transparency)
			end
		end
		warn("folder does not have a Part as child")
		return 0
	else
		-- todo: check if item is a cage
		warn("Try to modify transparency on inavlid item "..item.Name)
		return 0
	end
end

return getTransparency