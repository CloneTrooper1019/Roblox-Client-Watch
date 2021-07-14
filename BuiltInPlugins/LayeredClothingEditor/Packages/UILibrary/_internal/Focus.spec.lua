return function()
	local Library = script.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Focus = require(script.Parent.Focus)
	local ShowOnTop = Focus.ShowOnTop
	local CaptureFocus = Focus.CaptureFocus
	local KeyboardListener = Focus.KeyboardListener

	describe("ShowOnTop", function()
		local function createTestShowOnTop(children, container)
			return Roact.createElement(MockWrapper, {
				Container = container,
			}, {
				ShowOnTop = Roact.createElement(ShowOnTop, {}, children)
			})
		end

		it("should create and destroy without errors", function()
			local element = createTestShowOnTop()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should render correctly", function()
			local container = Instance.new("Folder")
			local element = createTestShowOnTop({}, container)
			local instance = Roact.mount(element)

			local gui = container:FindFirstChild("MockGui")
			expect(gui).to.be.ok()
			expect(gui.TopLevelFrame).to.be.ok()
			Roact.unmount(instance)
		end)

		it("should render its children", function()
			local container = Instance.new("Folder")
			local element = createTestShowOnTop({
				ChildFrame = Roact.createElement("Frame"),
			}, container)
			local instance = Roact.mount(element)

			local gui = container:FindFirstChild("MockGui")
			expect(gui.TopLevelFrame.ChildFrame).to.be.ok()
			Roact.unmount(instance)
		end)
	end)

	describe("CaptureFocus", function()
		local function createTestCaptureFocus(children, container)
			return Roact.createElement(MockWrapper, {
				Container = container,
			}, {
				CaptureFocus = Roact.createElement(CaptureFocus, {}, children)
			})
		end

		it("should create and destroy without errors", function()
			local element = createTestCaptureFocus()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should render correctly", function()
			local container = Instance.new("Folder")
			local element = createTestCaptureFocus({}, container)
			local instance = Roact.mount(element)

			local gui = container:FindFirstChild("MockGui")
			expect(gui).to.be.ok()
			expect(gui.TopLevelDetector).to.be.ok()
			expect(gui.TopLevelDetector.ScrollBlocker).to.be.ok()
			Roact.unmount(instance)
		end)

		it("should render its children", function()
			local container = Instance.new("Folder")
			local element = createTestCaptureFocus({
				ChildFrame = Roact.createElement("Frame"),
			}, container)
			local instance = Roact.mount(element)

			local gui = container:FindFirstChild("MockGui")
			expect(gui.TopLevelDetector.ScrollBlocker.ChildFrame).to.be.ok()
			Roact.unmount(instance)
		end)
	end)

	describe("KeyboardListener", function()
		local function createTestKeyboardListener(container)
			return Roact.createElement(MockWrapper, {
				Container = container,
			}, {
				KeyboardListener = Roact.createElement(KeyboardListener)
			})
		end

		it("should create and destroy without errors", function()
			local element = createTestKeyboardListener()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should render correctly", function()
			local container = Instance.new("Folder")
			local element = createTestKeyboardListener(container)
			local instance = Roact.mount(element)

			local gui = container:FindFirstChild("MockGui")
			expect(gui).to.be.ok()
			expect(gui.TopLevelFrame).to.be.ok()
			expect(gui.TopLevelFrame.Listener).to.be.ok()
			Roact.unmount(instance)
		end)
	end)
end