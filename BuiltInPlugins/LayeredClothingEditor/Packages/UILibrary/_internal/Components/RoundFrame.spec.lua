return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local RoundFrame = require(script.Parent.RoundFrame)

	local function createTestRoundFrame(props, children)
		return Roact.createElement(MockWrapper, {}, {
			RoundFrame = Roact.createElement(RoundFrame, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestRoundFrame()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundFrame(), container)
		local frame = container:FindFirstChildOfClass("ImageLabel")

		expect(frame).to.be.ok()
		expect(frame.Border).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should hide its border if BorderSizePixel == 0", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundFrame({
			BorderSizePixel = 0,
		}), container)
		local frame = container:FindFirstChildOfClass("ImageLabel")

		expect(frame.Border.ImageTransparency).to.equal(1)

		Roact.unmount(instance)
	end)

	it("should be an ImageLabel if OnActivated is undefined", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundFrame(), container)
		local frame = container:FindFirstChildOfClass("ImageLabel")

		expect(frame:IsA("ImageLabel")).to.equal(true)

		Roact.unmount(instance)
	end)

	it("should be an ImageButton if OnActivated is defined", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundFrame({
			OnActivated = function()
			end,
		}), container)
		local frame = container:FindFirstChildOfClass("ImageButton")

		expect(frame:IsA("ImageButton")).to.equal(true)

		Roact.unmount(instance)
	end)

	it("should accept children", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundFrame({}, {
			Child = Roact.createElement("Frame"),
		}), container)
		local frame = container:FindFirstChildOfClass("ImageLabel")

		expect(frame.Border).to.be.ok()
		expect(frame.Border.Child).to.be.ok()

		Roact.unmount(instance)
	end)
end