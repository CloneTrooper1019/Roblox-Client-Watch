return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local RoundTextButton = require(script.Parent.RoundTextButton)

	local function createTestRoundTextButton()
		return Roact.createElement(MockWrapper, {}, {
			RoundTextButton = Roact.createElement(RoundTextButton, {
				Active = true,
				Style = {},
				Name = "Name",
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestRoundTextButton()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestRoundTextButton(), container)
		local button = container:FindFirstChildOfClass("ImageButton")

		expect(button.Border).to.be.ok()
		expect(button.Text).to.be.ok()

		Roact.unmount(instance)
	end)
end