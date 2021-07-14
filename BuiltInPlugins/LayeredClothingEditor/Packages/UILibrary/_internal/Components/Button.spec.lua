return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Button = require(script.Parent.Button)

	local function createTestButton(props, container)
		return Roact.createElement(MockWrapper, {
			Container = container,
		}, {
			Button = Roact.createElement(Button, props)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestButton({
			RenderContents = function()
			end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")

		local element = createTestButton({
			RenderContents = function()
			end,
		}, container)

		local instance = Roact.mount(element, container)

		local button = container:FindFirstChildOfClass("ImageButton")
		expect(button).to.be.ok()
		expect(button.Border).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should require a RenderContents function", function()
		local element = createTestButton()
		expect(function()
			Roact.mount(element)
		end).to.throw()

		element = createTestButton({
			RenderContents = true,
		})
		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)

	it("should render the children in RenderContents", function()
		local container = Instance.new("Folder")

		local element = createTestButton({
			RenderContents = function()
				return {
					SomeFrame = Roact.createElement("Frame"),
					OtherFrame = Roact.createElement("Frame"),
				}
			end,
		}, container)

		local instance = Roact.mount(element, container)

		local button = container:FindFirstChildOfClass("ImageButton")
		expect(button).to.be.ok()
		expect(button.Border).to.be.ok()
		expect(button.Border.SomeFrame).to.be.ok()
		expect(button.Border.OtherFrame).to.be.ok()

		Roact.unmount(instance)
	end)
end