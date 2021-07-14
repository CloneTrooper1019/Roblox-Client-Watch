return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Focus = ContextServices.Focus
	local provide = ContextServices.provide
	local DragListener = require(script.Parent)

	local function createTestDragListener(container)
		local target = container or Instance.new("ScreenGui")
		local focus = Focus.new(target)
		return provide({focus}, {
			DragListener = Roact.createElement(DragListener)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestDragListener()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("ScreenGui")
		local element = createTestDragListener(container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("ImageButton")
		expect(frame.ScrollBlocker.Listener).to.be.ok()
		Roact.unmount(instance)
	end)
end