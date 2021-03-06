local Plugin = script.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local ImportLocal = require(script.Parent.ImportLocal)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(ImportLocal)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
