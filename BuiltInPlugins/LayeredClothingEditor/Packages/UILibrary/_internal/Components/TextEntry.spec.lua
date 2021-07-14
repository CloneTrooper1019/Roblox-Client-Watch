return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local TextEntry = require(script.Parent.TextEntry)

	local function createTestTextEntry(text, visible)
		return Roact.createElement(MockWrapper, {}, {
			TextEntry = Roact.createElement(TextEntry, {
				Text = text,
				Visible = visible,
				TextSize = 22,
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestTextEntry()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestTextEntry("", true), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Text).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should hide its text when not visible", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestTextEntry("", false), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame.Text.Visible).to.equal(false)

		Roact.unmount(instance)
	end)
end