local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)

local MockProvider = require(Plugin.Src.TestHelpers.MockProvider)

local ToolSelectionListener = require(script.Parent.ToolSelectionListener)

return function()
	it("should create and destroy without errors", function()
		local element = MockProvider.createElementWithMockContext(ToolSelectionListener)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
