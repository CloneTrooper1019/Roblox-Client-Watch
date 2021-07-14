return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)

	local provideMockContext = require(Framework.TestHelpers.provideMockContext)
	local ScrollingFrame = require(script.Parent)

	local function createTestScrollingFrame(props, children)
		return provideMockContext(nil, {
			ScrollingFrame = Roact.createElement(ScrollingFrame, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestScrollingFrame({},
		{
			TextButton = Roact.createElement("TextButton", {})
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end