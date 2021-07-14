return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local Provider = require(script.Parent.Provider)
	local ContextItem = require(script.Parent.ContextItem)

	it("should create and destroy without errors", function()
		local testItem = ContextItem:extend("TestItem")
		local element = Roact.createElement(Provider, {
			ContextItem = testItem,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect a ContextItem prop", function()
		local element = Roact.createElement(Provider)
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect the ContextItem prop to be a ContextItem", function()
		local element = Roact.createElement(Provider, {
			ContextItem = {},
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should render its child", function()
		local container = Instance.new("Folder")
		local testItem = ContextItem:extend("TestItem")

		local element = Roact.createElement(Provider, {
			ContextItem = testItem,
		}, {
			Frame = Roact.createElement("Frame"),
		})

		local instance = Roact.mount(element, container)
		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should provide the ContextItem to context", function()
		local confirmed = false

		local testItem = ContextItem:extend("TestItem")
		local Component = Roact.PureComponent:extend("TestComponent")
		function Component:render()
			if self._context[testItem.Key] then
				confirmed = true
			end
		end

		local element = Roact.createElement(Provider, {
			ContextItem = testItem,
		}, {
			Component = Roact.createElement(Component),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)

		expect(confirmed).to.equal(true)
	end)
end