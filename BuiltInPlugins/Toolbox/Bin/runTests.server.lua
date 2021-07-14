-- Fast flags
require(script.Parent.defineLuaFlags)

local Plugin = script.Parent.Parent

--[[
	RefactorFlags needs to be required and updated directly; before Framework's init
	is required (so that any files that Framework's init requires get the correct values).
]]
local RefactorFlags = require(Plugin.Libs.Framework.Util.RefactorFlags)
RefactorFlags.THEME_REFACTOR = true

local DebugFlags = require(Plugin.Core.Util.DebugFlags)

local TestsFolderPlugin = Plugin.Core

-- This ensures that coverage stats include all module scripts within the plugin.
-- And also that all ModuleScripts can be loaded without error
local function requireAllModuleScripts()
	local descendants = Plugin.Core:GetDescendants()

	for _, descendant in ipairs(descendants) do
		if descendant:IsA("ModuleScript") then
			require(descendant)
		end
	end
end

if not DebugFlags.shouldRunTests() and not DebugFlags.shouldRunRhodiumTests() then
	-- Prevent TestEZ from being required unless at least one of the DebugFlags is enabled
	-- because requiring TestEZ initialises TestService
	return
end

local isCli, processService = pcall(function()
	return game:GetService("ProcessService")
end)

-- Run the function and handle exit status correctly if in CLI
local function runAndCheck(func)
	local ok, err = pcall(func)

	if isCli then
		if not ok then
			warn(err)
			warn(debug.traceback())
		end
		processService:ExitAsync(ok and 0 or 1)
	elseif not ok then
		error(err)
	end
end

runAndCheck(function()
	local TestEZ = require(Plugin.Packages.Dev.TestEZ)
	local TestBootstrap = TestEZ.TestBootstrap
	local TeamCityReporter = TestEZ.Reporters.TeamCityReporter
	local reporter = TestEZ.Reporters.TextReporter
	if DebugFlags.logTestsQuiet() then
		reporter = TestEZ.Reporters.TextReporterQuiet
	end
	reporter = _G["TEAMCITY"] and TeamCityReporter or reporter

	if DebugFlags.shouldRunTests() then
		requireAllModuleScripts()

		print("----- All " ..Plugin.Name.. " Tests ------")
		TestBootstrap:run({TestsFolderPlugin}, reporter)
		print("----------------------------------")
	end

	if DebugFlags.shouldRunRhodiumTests() then
		print("----- All " ..Plugin.Name.. " Rhodium Tests ------")
		TestBootstrap:run({Plugin.RhodiumTests}, reporter)
		print("----------------------------------")
	end
end)