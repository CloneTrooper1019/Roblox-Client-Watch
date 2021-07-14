return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Separator = require(script.Parent.Separator)

	local function createTestSeparator(props)
		return Roact.createElement(MockWrapper, {}, {
			Separator = Roact.createElement(Separator, props)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestSeparator()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestSeparator(), container)
		local separator = container:FindFirstChildOfClass("Frame")

		expect(separator).to.be.ok()

		Roact.unmount(instance)
	end)
end