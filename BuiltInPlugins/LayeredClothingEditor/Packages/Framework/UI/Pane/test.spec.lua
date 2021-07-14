return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local Pane = require(script.Parent)

	local function createPane(props)
		props = props or {}
		return TestHelpers.provideMockContext(nil, {
			Pane = Roact.createElement(Pane, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createPane()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end