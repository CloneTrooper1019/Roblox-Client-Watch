return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Focus = ContextServices.Focus
	local provide = ContextServices.provide
	local KeyboardListener = require(script.Parent)

	local function createTestKeyboardListener(container)
		local target = container or Instance.new("ScreenGui")
		local focus = Focus.new(target)
		return provide({focus}, {
			KeyboardListener = Roact.createElement(KeyboardListener)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestKeyboardListener()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("ScreenGui")
		local element = createTestKeyboardListener(container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame.Listener).to.be.ok()
		Roact.unmount(instance)
	end)
end