return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Focus = ContextServices.Focus
	local provide = ContextServices.provide
	local CaptureFocus = require(script.Parent)

	local function createTestCaptureFocus(children, container)
		local target = container or Instance.new("ScreenGui")
		local focus = Focus.new(target)
		return provide({focus}, {
			CaptureFocus = Roact.createElement(CaptureFocus, {
				OnFocusLost = function()
				end,
			}, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestCaptureFocus()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("ScreenGui")
		local element = createTestCaptureFocus({}, container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("ImageButton")
		expect(frame).to.be.ok()
		expect(frame.ScrollBlocker).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local container = Instance.new("ScreenGui")
		local element = createTestCaptureFocus({
			ChildFrame = Roact.createElement("Frame"),
		}, container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("ImageButton")
		expect(frame.ScrollBlocker.ChildFrame).to.be.ok()
		Roact.unmount(instance)
	end)
end