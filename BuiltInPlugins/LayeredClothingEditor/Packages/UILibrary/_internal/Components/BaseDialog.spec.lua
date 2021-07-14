return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local BaseDialog = require(script.Parent.BaseDialog)

	local function createTestBaseDialog(props, children, container)
		return Roact.createElement(MockWrapper, {
			Container = container,
		}, {
			BaseDialog = Roact.createElement(BaseDialog, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestBaseDialog({
			Buttons = {},
			RenderButton = function(item)
			end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")

		local element = createTestBaseDialog({
			Buttons = {},
			RenderButton = function(item)
			end,
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
		local element = createTestBaseDialog({
			RenderButton = function(item)
			end,
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()

		element = createTestBaseDialog({
			Buttons = true,
			RenderButton = function(item)
			end,
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)

	it("should require a RenderButtons function", function()
		local element = createTestBaseDialog({
			Buttons = {},
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()

		element = createTestBaseDialog({
			Buttons = {},
			RenderButton = true,
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)

	it("should render its buttons", function()
		local container = Instance.new("Folder")

		local element = createTestBaseDialog({
			Buttons = {"Frame"},
			RenderButton = function()
				return Roact.createElement("Frame")
			end,
		}, {}, container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("BillboardGui")
		local buttonContainer = gui.FocusProvider.Buttons
		expect(buttonContainer["1"]).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render its children", function()
		local container = Instance.new("Folder")

		local element = createTestBaseDialog({
			Buttons = {},
			RenderButton = function()
			end,
		}, {
			Frame = Roact.createElement("Frame"),
		}, container)

		local instance = Roact.mount(element, container)

		local gui = container:FindFirstChildOfClass("BillboardGui")
		expect(gui.FocusProvider.Content.Frame).to.be.ok()

		Roact.unmount(instance)
	end)
end