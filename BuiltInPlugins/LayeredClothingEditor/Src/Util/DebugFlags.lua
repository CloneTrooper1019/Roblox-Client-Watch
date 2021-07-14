local workspace = game:GetService("Workspace")

local DebugFlags = {}

local function checkFlag(flagName)
	local flags = workspace:FindFirstChild("LayeredClothingEditorFlags")
	if flags then
		return flags:FindFirstChild(flagName) and flags[flagName].Value
	else
		return false
	end
end

function DebugFlags.RunTests()
	return checkFlag("RunTests")
end

function DebugFlags.RunRhodiumTests()
	return checkFlag("RunRhodiumTests")
end

function DebugFlags.LogRoduxEvents()
	return checkFlag("LogRoduxEvents")
end

function DebugFlags.LogAnalytics()
	return checkFlag("LogAnalytics")
end

function DebugFlags.MockItemHasFullCage()
	return checkFlag("MockItemHasFullCage")
end

function DebugFlags.UseMockCages()
	return checkFlag("UseMockCages")
end

return DebugFlags