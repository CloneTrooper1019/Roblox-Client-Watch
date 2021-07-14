return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local DetailedDropdown = require(script.Parent.DetailedDropdown)

	local function createTestDetailedDropdown(props, children)
		return Roact.createElement(MockWrapper, {}, {
			DetailedDropdown = Roact.createElement(DetailedDropdown, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestDetailedDropdown()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestDetailedDropdown(), container)
		local button = container:FindFirstChildOfClass("ImageButton")

		expect(button).to.be.ok()
		expect(button.RoundFrame).to.be.ok()
		expect(button.ArrowIcon).to.be.ok()
		expect(button.TextLabel).to.be.ok()
		expect(button.TextLabel.Padding).to.be.ok()

		Roact.unmount(instance)
	end)
end