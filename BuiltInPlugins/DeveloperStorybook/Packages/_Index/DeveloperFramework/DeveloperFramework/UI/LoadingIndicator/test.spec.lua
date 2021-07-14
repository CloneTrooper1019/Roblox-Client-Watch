return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local LoadingIndicator = require(script.Parent)

	local function createTestLoadingIndicator(props)
		props = props or {}

		return TestHelpers.provideMockContext(nil, {
			LoadingIndicator = Roact.createElement(LoadingIndicator, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestLoadingIndicator()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end