local Plugin = script.Parent.Parent
local DebugFlags = require(Plugin.Src.Util.DebugFlags)

local themeRefactorFlags = require(Plugin.Packages.Framework.Util.RefactorFlags)
themeRefactorFlags.THEME_REFACTOR = true

local function runTests()
	local TestEZ = require(Plugin.Packages.Dev.TestEZ)
	local tests = Plugin.Src -- Where stores the package's unit tests

	local TestBootstrap = TestEZ.TestBootstrap
	local TextReporter = TestEZ.Reporters.TextReporter -- Remove Quiet to see output

	TestBootstrap:run({tests}, TextReporter)
end

--[[
local function runRhodiumTests()
	local TestEZ = require(Plugin.Packages.Dev.TestEZ)
	local tests = Plugin.RhodiumTests

	local TestBootstrap = TestEZ.TestBootstrap
	local TextReporter = TestEZ.Reporters.TextReporter -- Remove Quiet to see output

	TestBootstrap:run({tests}, TextReporter, false, true)
end
]]

-- Do not check in as true!
local SHOULD_RUN_TESTS = DebugFlags.RunTests()
local SHOULD_RUN_RHODIUM_TESTS = DebugFlags.RunRhodiumTests()

if SHOULD_RUN_TESTS then
	print("----- All " ..script.Parent.Parent.Name.. " Tests ------")
	runTests()
	print("----------------------------------")
end

if SHOULD_RUN_RHODIUM_TESTS then
	print("----- All " ..script.Parent.Parent.Name.. " Rhodium Tests ------")
	-- TODO: Fix Rhodium tests, they have to be rewritten after last major design change
	--runRhodiumTests()
	print("----------------------------------")
	game:GetService("ProcessService"):ExitAsync(0)
end
