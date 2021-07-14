return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local DropShadow = require(script.Parent)

	local function createTestDropShadow(props)
		props = props or {}

		return TestHelpers.provideMockContext(nil, {
			DropShadow = Roact.createElement(DropShadow, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestDropShadow()
		local instance = Roact.mount(element)

		Roact.unmount(instance)
	end)
end