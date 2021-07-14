--[[
	Framework is not a buildable plugin itself, so it cannot specify its
	own dev dependencies because they will not be installed by Rotriever, so
	dependency inject TestEZ here.

	Developer Storybook should be the only plugin that needs to run
	DeveloperFramework tests.
]]
local Framework = script.Parent.Parent

local Dash = require(Framework.packages.Dash)
local filter = Dash.filter

local function runFrameworkTests(TestEZ, ...)
	local TestBootstrap = TestEZ.TestBootstrap
	-- Do not run the tests of the packages
	local children = filter(Framework:GetChildren(), function(child)
		return child.Name ~= "packages"
	end)
	return TestBootstrap:run(children, ...)
end

return runFrameworkTests