--[[
	Performs common initialisation for DeveloperStorybook at most once.
]]
local commonInitCalled = false

return function()
	if commonInitCalled then
		return
	end
	commonInitCalled = true

	local Main = script.Parent.Parent.Parent
	local Roact = require(Main.Packages.Roact)

	local RefactorFlags = require(Main.Packages._Index.DeveloperFramework.DeveloperFramework.Util.RefactorFlags)
	RefactorFlags.THEME_REFACTOR = true

	Roact.setGlobalConfig({
		elementTracing = true,
		propValidation = true,
		typeChecks = true
	})
end
