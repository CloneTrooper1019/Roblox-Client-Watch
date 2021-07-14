return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local StyledDialog = require(script.Parent.StyledDialog)

	local function createTestStyledDialog(props, children, container)
		return Roact.createElement(MockWrapper, {
			Container = container,
		}, {
			StyledDialog = Roact.createElement(StyledDialog, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestStyledDialog({
			Buttons = {},
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")

		local element = createTestStyledDialog({
			Buttons = {},
		}, {}, container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("BillboardGui")
		expect(gui).to.be.ok()
		expect(gui.FocusProvider).to.be.ok()
		expect(gui.FocusProvider.Padding).to.be.ok()
		expect(gui.FocusProvider.Content).to.be.ok()
		expect(gui.FocusProvider.Buttons).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should require a Buttons table", function()
		local element = createTestStyledDialog()
		expect(function()
			Roact.mount(element)
		end).to.throw()

		element = createTestStyledDialog({
			Buttons = true,
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)

	it("should create a Button for each button", function()
		local container = Instance.new("Folder")

		local element = createTestStyledDialog({
			Buttons = {
				{Key = "Test", Text = "TestText"},
				{Key = "Test2", Text = "TestText2"},
			},
		}, {}, container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("BillboardGui")
		expect(gui.FocusProvider.Buttons).to.be.ok()
		expect(gui.FocusProvider.Buttons[1]).to.be.ok()
		expect(gui.FocusProvider.Buttons[2]).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local container = Instance.new("Folder")

		local element = createTestStyledDialog({
			Buttons = {},
		}, {
			Frame = Roact.createElement("Frame"),
		}, container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("BillboardGui")
		expect(gui.FocusProvider.Content.Frame).to.be.ok()

		Roact.unmount(instance)
	end)
end