return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local StyledScrollingFrame = require(script.Parent.StyledScrollingFrame)

	local function createTestScrollingFrame(props, children)
		return Roact.createElement(MockWrapper, {}, {
			ScrollingFrame = Roact.createElement(StyledScrollingFrame, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestScrollingFrame()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestScrollingFrame(), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()
		expect(frame.ScrollBarBackground).to.be.ok()
		expect(frame.ScrollingFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render its children in the ScrollingFrame", function()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestScrollingFrame({}, {
			ChildFrame = Roact.createElement("Frame"),
		}), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()
		expect(frame.ScrollBarBackground).to.be.ok()
		expect(frame.ScrollingFrame).to.be.ok()
		expect(frame.ScrollingFrame.ChildFrame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should add padding to both sides of the ScrollBar", function()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestScrollingFrame({
			ScrollBarPadding = 2,
			ScrollBarThickness = 8,
		}), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()
		expect(frame.ScrollBarBackground).to.be.ok()
		expect(frame.ScrollBarBackground.Size.X.Offset).to.equal(12)

		Roact.unmount(instance)
	end)
end