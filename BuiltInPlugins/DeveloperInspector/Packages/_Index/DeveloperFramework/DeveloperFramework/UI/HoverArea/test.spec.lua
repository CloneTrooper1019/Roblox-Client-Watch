return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Mouse = ContextServices.Mouse
	local provide = ContextServices.provide
	local HoverArea = require(script.Parent)

	local function testMouse()
		return {
			Icon = "rbxasset://SystemCursors/Arrow",
		}
	end

	local function createTestHoverArea()
		local mouse = Mouse.new(testMouse())
		return provide({mouse}, {
			HoverArea = Roact.createElement(HoverArea, {
				Cursor = "Arrow",
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestHoverArea()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestHoverArea()
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)
end