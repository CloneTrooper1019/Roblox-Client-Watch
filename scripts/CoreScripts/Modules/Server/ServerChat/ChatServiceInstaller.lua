local runnerScriptName = "ChatServiceRunner"

local installDirectory = game:GetService("Chat")
local ServerScriptService = game:GetService("ServerScriptService")

local RobloxGui = game:GetService("CoreGui"):WaitForChild("RobloxGui")
local FFlagEnableForkedChatAnalytics = require(RobloxGui.Modules.Common.Flags.FFlagEnableForkedChatAnalytics)
local SendChatAnalytics
if FFlagEnableForkedChatAnalytics then
	SendChatAnalytics = require(RobloxGui.Modules.Server.SendChatAnalytics)
end

local function LoadScript(name, parent)
	local originalModule = script.Parent:WaitForChild(name)
	local script = Instance.new("Script")
	script.Name = name
	script.Source = originalModule.Source
	script.Parent = parent
	return script
end

local function LoadModule(location, name, parent)
	local originalModule = location:WaitForChild(name)
	local module = Instance.new("ModuleScript")
	module.Name = name
	module.Source = originalModule.Source
	module.Parent = parent
	return module
end

local function GetBoolValue(parent, name, defaultValue)
	local boolValue = parent:FindFirstChild(name)
	if boolValue then
		if boolValue:IsA("BoolValue") then
			return boolValue.Value
		end
	end
	return defaultValue
end

local function makeDefaultLocalizationTable(parent)
	local defaultChatLocalization = Instance.new("LocalizationTable")
	defaultChatLocalization.Name = "ChatLocalization"
	defaultChatLocalization.Archivable = false
	defaultChatLocalization.SourceLocaleId = "en-us"
	defaultChatLocalization:SetEntries(require(script.Parent:WaitForChild("DefaultChatLocalization")))
	defaultChatLocalization:SetIsExemptFromUGCAnalytics(true)
	defaultChatLocalization.Parent = parent;
end

local function Install()
	local eventTable = {}
	local existingChatLocalization = installDirectory:FindFirstChild("ChatLocalization")

	if existingChatLocalization then
		if existingChatLocalization:IsA("LocalizationTable" ) then
			existingChatLocalization:SetIsExemptFromUGCAnalytics(true)
		end
	else
		makeDefaultLocalizationTable(installDirectory)
	end

	local chatServiceRunnerArchivable = true
	local ChatServiceRunner = installDirectory:FindFirstChild(runnerScriptName)
	if not ChatServiceRunner then
		chatServiceRunnerArchivable = false
		ChatServiceRunner = LoadScript(runnerScriptName, installDirectory)

		LoadModule(script.Parent, "ChatService", ChatServiceRunner)
		LoadModule(script.Parent, "ChatChannel", ChatServiceRunner)
		LoadModule(script.Parent, "Speaker", ChatServiceRunner)
		LoadModule(script.Parent, "Util", ChatServiceRunner)
	elseif FFlagEnableForkedChatAnalytics then
		eventTable[runnerScriptName] = "True"
	end

	local ChatModules = installDirectory:FindFirstChild("ChatModules")
	if not ChatModules then
		ChatModules = Instance.new("Folder")
		ChatModules.Name = "ChatModules"
		ChatModules.Archivable = false

		local InsertDefaults = Instance.new("BoolValue")
		InsertDefaults.Name = "InsertDefaultModules"
		InsertDefaults.Value = true
		InsertDefaults.Parent = ChatModules

		ChatModules.Parent = installDirectory
	end

	local shouldInsertDefaultModules = GetBoolValue(ChatModules, "InsertDefaultModules", false)

	if shouldInsertDefaultModules then
		if not ChatModules:FindFirstChild("Utility") then
			local Utility = Instance.new("Folder")
			Utility.Name = "Utility"
			Utility.Parent = ChatModules
		end

		local defaultChatModules = script.Parent.DefaultChatModules:GetChildren()
		for i = 1, #defaultChatModules do
			if defaultChatModules.className ~= "Folder" and not ChatModules:FindFirstChild(defaultChatModules[i].Name) then
				LoadModule(script.Parent.DefaultChatModules, defaultChatModules[i].Name, ChatModules)
			elseif FFlagEnableForkedChatAnalytics and defaultChatModules.className ~= "Folder" then
				eventTable[defaultChatModules[i].Name] = "True"
			end
		end

		for _, utilityModule in pairs(script.Parent.DefaultChatModules.Utility:GetChildren()) do
			if not ChatModules.Utility:FindFirstChild(utilityModule.Name) then
				LoadModule(script.Parent.DefaultChatModules.Utility, utilityModule.Name, ChatModules.Utility)
			elseif FFlagEnableForkedChatAnalytics then
				eventTable[utilityModule.Name] = "True"
			end
		end
	end

	if not ServerScriptService:FindFirstChild(runnerScriptName) then
		local ChatServiceRunnerCopy = ChatServiceRunner:Clone()
		ChatServiceRunnerCopy.Archivable = false
		ChatServiceRunnerCopy.Parent = ServerScriptService
	end

	ChatServiceRunner.Archivable = chatServiceRunnerArchivable

	if FFlagEnableForkedChatAnalytics then
		SendChatAnalytics("LoadServerDefaultChatForkedModules", eventTable)
	end
end

return Install
