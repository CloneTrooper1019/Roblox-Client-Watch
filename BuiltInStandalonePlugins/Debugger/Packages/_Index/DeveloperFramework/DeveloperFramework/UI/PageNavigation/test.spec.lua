return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local PageNavigation = require(script.Parent)

	local function createPageNavigation(props)
		props = props or {}

		return TestHelpers.provideMockContext(nil, {
			PageNavigation = Roact.createElement(PageNavigation, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createPageNavigation({
			PageIndex = 1,
			PageCount = 2,
			OnPageChange = function() end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
