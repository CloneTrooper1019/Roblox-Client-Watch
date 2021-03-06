local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local MapSettingsWithPreview = require(script.Parent.MapSettingsWithPreview)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(MapSettingsWithPreview)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
