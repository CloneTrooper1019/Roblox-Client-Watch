return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local MultiLineTextInput = require(script.Parent)

	local function createTestTextInput(props)
		props = props or {}

		return TestHelpers.provideMockContext(nil, {
			MultiLineTextInput = Roact.createElement(MultiLineTextInput, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestTextInput({
			Size = UDim2.new(1, 0, 1, 0),
			TextInputProps = {
				Text = "textbox"
			},
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end