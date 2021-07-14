-- TODO: Delete file when FFlagRemoveUILibraryTimeline is retired
return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Scrubber = require(script.Parent.Scrubber)

	local function createTestScrubber(showHead)
		return Roact.createElement(MockWrapper, {}, {
			Scrubber = Roact.createElement(Scrubber, {
				Height = 1000,
				HeadSize = UDim2.new(0, 48, 0, 48),
				ShowHead = showHead,
				AnchorPoint = Vector2.new(0.5, 0),
				Thickness = 1,
			})
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestScrubber(true)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)


	describe("should render correctly", function()
		it("should render with head correctly", function()
			local container = Instance.new("Folder")
			local instance = Roact.mount(createTestScrubber(true), container)
			local frame = container:FindFirstChildOfClass("Frame")

			expect(frame).to.be.ok()
			expect(frame["1"]).to.be.ok()
			expect(frame["2"]).to.be.ok()

			Roact.unmount(instance)
		end)

		it("should render without head correctly", function()
			local container = Instance.new("Folder")
			local instance = Roact.mount(createTestScrubber(false), container)
			local frame = container:FindFirstChildOfClass("Frame")

			expect(frame).to.be.ok()
			expect(#frame:GetChildren()).to.be.equal(1)
			expect(frame["1"]).to.be.ok()

			Roact.unmount(instance)
		end)
	end)
end