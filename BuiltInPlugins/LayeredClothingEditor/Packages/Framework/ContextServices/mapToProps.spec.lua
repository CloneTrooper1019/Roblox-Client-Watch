return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local mapToProps = require(script.Parent.mapToProps)
	local ContextItem = require(script.Parent.ContextItem)
	local Provider = require(script.Parent.Provider)
	local provide = require(script.Parent.provide)

	local Util = require(Framework.Util)
	local Signal = Util.Signal

	it("should throw if called before defining Render", function()
		expect(function()
			local Component = Roact.PureComponent:extend("TestComponent")

			mapToProps(Component, {})

			function Component:render()
			end
		end).to.throw()
	end)

	it("should expect a ContextMap table", function()
		expect(function()
			local Component = Roact.PureComponent:extend("TestComponent")
			function Component:render()
			end

			mapToProps(Component)
		end).to.throw()
	end)

	it("should pass items into props according to the ContextMap table", function()
		local confirmed = false

		local testItem = ContextItem:extend("TestItem")
		function testItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
			}, {root})
		end
		function testItem:confirm()
			confirmed = true
		end

		local Component = Roact.PureComponent:extend("TestComponent")
		function Component:render()
			local props = self.props
			local test = props.Test
			test:confirm()
		end
		mapToProps(Component, {
			Test = testItem,
		})

		local tree = provide({testItem}, {
			Component = Roact.createElement(Component),
		})
		local instance = Roact.mount(tree)
		Roact.unmount(instance)

		expect(confirmed).to.equal(true)
	end)

	it("should re-render the component when any ContextItem changes", function()
		local renders = 0

		local testItem = ContextItem:extend("TestItem")
		testItem.update = Signal.new()
		function testItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
				UpdateSignal = self.update,
			}, {root})
		end
		function testItem:fireUpdate()
			self.update:Fire(self)
		end

		local otherItem = ContextItem:extend("OtherItem")
		otherItem.update = Signal.new()
		function otherItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
				UpdateSignal = self.update,
			}, {root})
		end
		function otherItem:fireUpdate()
			self.update:Fire(self)
		end

		local Component = Roact.PureComponent:extend("TestComponent")
		function Component:render()
			renders = renders + 1
		end
		mapToProps(Component, {
			Test = testItem,
			Other = otherItem,
		})

		local tree = provide({testItem, otherItem}, {
			Component = Roact.createElement(Component),
		})
		local instance = Roact.mount(tree)

		expect(renders).to.equal(1)
		testItem:fireUpdate()
		expect(renders).to.equal(2)
		otherItem:fireUpdate()
		expect(renders).to.equal(3)
		Roact.unmount(instance)
	end)
end