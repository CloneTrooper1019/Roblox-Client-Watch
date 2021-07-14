return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local DropShadow = require(script.Parent.DropShadow)

	local function createTestDropShadow(props)
		return Roact.createElement(MockWrapper, {}, {
			DropShadow = Roact.createElement(DropShadow, props)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestDropShadow()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestDropShadow(), container)
		local shadow = container:FindFirstChildOfClass("ImageLabel")

		expect(shadow).to.be.ok()

		Roact.unmount(instance)
	end)
end