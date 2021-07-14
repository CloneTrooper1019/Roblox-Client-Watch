local Services = {}

function Services.hasInternalPermission()
	local RunService = game:GetService("RunService")
	if RunService:IsStudio() then
		return game:GetService("StudioService"):HasInternalPermission()
	elseif Services.isRunningUnderCLI() then
		return true
	else
		return false
	end
end

function Services.isRunningUnderCLI()
	local flag = script.Parent:FindFirstChild("RunningUnderCLI")
	return flag and flag.Value or false
end

function Services.getStudioService()
	return Services.isRunningUnderCLI() and Instance.new("Frame") or game:GetService("StudioService")
end

function Services.getCoreGui()
	return Services.isRunningUnderCLI() and Instance.new("Frame") or game:GetService("CoreGui")
end

function Services.getRobloxPluginGuiService()
	return Services.isRunningUnderCLI() and Instance.new("Frame") or game:GetService("RobloxPluginGuiService")
end

return Services
