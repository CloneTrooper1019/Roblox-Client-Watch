return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Focus = ContextServices.Focus
	local provide = ContextServices.provide
	local ShowOnTop = require(script.Parent)

	local function createTestShowOnTop(children, container)
		local target = container or Instance.new("ScreenGui")
		local focus = Focus.new(target)
		return provide({focus}, {
			ShowOnTop = Roact.createElement(ShowOnTop, {}, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestShowOnTop()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("ScreenGui")
		local element = createTestShowOnTop({}, container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local container = Instance.new("ScreenGui")
		local element = createTestShowOnTop({
			ChildFrame = Roact.createElement("Frame"),
		}, container)
		local instance = Roact.mount(element)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame.ChildFrame).to.be.ok()
		Roact.unmount(instance)
	end)
end