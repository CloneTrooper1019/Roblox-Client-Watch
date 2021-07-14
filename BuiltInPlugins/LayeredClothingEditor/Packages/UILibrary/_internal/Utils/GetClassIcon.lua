local StudioService  = game:GetService("StudioService")

local function GetClassIcon(instance)
	local className = instance.ClassName
	if instance.IsA then
		if instance:IsA("JointInstance") and className == "ManualWeld" or className == "ManualGlue" then
			return StudioService:GetClassIcon("JointInstance")
		end
	end
	return StudioService:GetClassIcon(className)
end

return GetClassIcon
