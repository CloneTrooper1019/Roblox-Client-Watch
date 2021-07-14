return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provideMockContext = require(Framework.TestHelpers.provideMockContext)

	local SelectInput = require(script.Parent)

	local function createSelectInput(props)
		props = props or {}

		return provideMockContext(nil, {
			SelectInput = Roact.createElement(SelectInput, props),
		})
	end

	it("should create and destroy without errors", function()

		local element = createSelectInput({
			SelectedIndex = 0,
			Items = { "a", "b", "c", "d" },
			OnItemActivated = function() end
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end