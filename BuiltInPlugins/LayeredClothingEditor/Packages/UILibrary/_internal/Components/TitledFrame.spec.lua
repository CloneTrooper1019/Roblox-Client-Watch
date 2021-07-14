return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local TitledFrame = require(script.Parent.TitledFrame)


	local function createTestTitledFrame()
		return Roact.createElement(MockWrapper, {}, {
			TitledFrame = Roact.createElement(TitledFrame, {
				Title = "Title",
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestTitledFrame()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestTitledFrame(), container)
		local titledFrame = container:FindFirstChildOfClass("Frame")

		expect(titledFrame.Title).to.be.ok()
		expect(titledFrame.Content).to.be.ok()

		Roact.unmount(instance)
	end)
end