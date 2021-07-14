return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local DragTarget = require(script.Parent.DragTarget)

	local function createTestDragTarget(container)
		return Roact.createElement(MockWrapper, {
			Container = container,
		}, {
			DragTarget = Roact.createElement(DragTarget)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestDragTarget()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")

		local element = createTestDragTarget(container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChild("MockGui")
		expect(gui).to.be.ok()
		expect(gui.TopLevelDetector).to.be.ok()
		expect(gui.TopLevelDetector.ScrollBlocker).to.be.ok()
		expect(gui.TopLevelDetector.ScrollBlocker.DragListener).to.be.ok()

		Roact.unmount(instance)
	end)
end