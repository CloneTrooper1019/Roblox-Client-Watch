return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Tooltip = require(script.Parent.Tooltip)

	local function createTestTooltip(props)
		return Roact.createElement(MockWrapper, {}, {
			Tooltip = Roact.createElement(Tooltip, props)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestTooltip()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestTooltip(), container)
		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()

		Roact.unmount(instance)
	end)
end