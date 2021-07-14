return function()
	local Framework = script.Parent.Parent
	local Signal = require(Framework.Util.Signal)
	local Roact = require(Framework.Parent.Roact)
	local ContextItem = require(script.Parent.ContextItem)
	local ContextServices = require(Framework.ContextServices)

	it("should be an abstract class", function()
		expect(ContextItem.new).never.to.be.ok()
		expect(function()
			ContextItem.new()
		end).to.throw()
	end)

	it("should be extendable", function()
		local testItem = ContextItem:extend("TestItem")
		expect(testItem).to.be.ok()
	end)

	it("should have a name", function()
		local testItem = ContextItem:extend("TestItem")
		expect(testItem.__name).to.equal("TestItem")
	end)

	it("should have a unique key", function()
		local testItem = ContextItem:extend("TestItem")
		local testItem2 = ContextItem:extend("TestItem")
		expect(testItem2.Key).never.to.equal(testItem.Key)
	end)

	it("should require overriding createProvider", function()
		local testItem = ContextItem:extend("TestItem")
		expect(function()
			testItem:createProvider()
		end).to.throw()

		function testItem:createProvider()
		end

		testItem:createProvider()
	end)

	describe("ContextItem:createSimple() get method", function()
		it("should require a name be passed", function()
			expect(function()
				ContextItem:createSimple("Foo")
			end).to.never.throw()

			expect(function()
				ContextItem:createSimple()
			end).to.throw()

			expect(function()
				ContextItem:createSimple(2)
			end).to.throw()
		end)

		it("should function as a context item", function()
			local data = {
				_value = 5,
				_changed = Signal.new()
			}

			local function setValue(newValue)
				data._value = newValue
				data._changed:Fire()
			end

			local Foo = ContextItem:createSimple("Foo", {
				getValues = function(obj) return obj._value end,
				getChangedSignal = function(obj) return obj._changed end
			})

			local foo = Foo.new(data)
			expect(foo:get()).to.equal(data._value)

			local renderCount = 0

			local TestComponent = Roact.PureComponent:extend("TestComponent")

			function TestComponent:render()
				renderCount = renderCount + 1
				expect(self.props.Foo:get()).to.equal(data._value)
				return nil
			end

			ContextServices.mapToProps(TestComponent, {Foo = Foo})

			local TestTopLevelComponent = Roact.PureComponent:extend("TestTopLevelComponent")

			function TestTopLevelComponent:render()
				return ContextServices.provide({
					self.props.foo,
				}, {
					TestComponent = Roact.createElement(TestComponent),
				})
			end

			local handle = Roact.mount(Roact.createElement(TestTopLevelComponent, {foo = foo}))

			expect(renderCount).to.equal(1)
			setValue(6)
			expect(renderCount).to.equal(2)
			setValue(7)
			expect(renderCount).to.equal(3)

			Roact.unmount(handle)
			foo:destroy()
		end)
	end)

	describe("ContextItem:createSimple() get method", function()
		it("should return the obj if no get method is provided", function()
			local FooItem = ContextItem:createSimple("Foo")
			local data = {}
			local foo = FooItem.new(data)
			expect(foo:get()).to.equal(data)
		end)

		it("should call the get method if it is provided", function()
			local getWasCalled = false

			local data = {}

			local FooItem = ContextItem:createSimple("Foo", {
				getValues = function(obj)
					getWasCalled = true
					expect(obj).to.equal(data)
					return "test"
				end
			})

			local foo = FooItem.new(data)
			expect(foo:get()).to.equal("test")
			expect(getWasCalled).to.equal(true)
		end)
	end)

	describe("ContextItem:createSimple() update signal", function()
		it("should connect to the update signal if no function is provided", function()
			local FooItem = ContextItem:createSimple("Foo")
			local foo = FooItem.new({})
			expect(foo._updateSignal).to.equal(nil)
			expect(foo._connection).to.equal(nil)
		end)

		it("should connect to the given signal", function()
			local getSignalWasCalled = false
			local data = {}
			local signal = Signal.new()

			local FooItem = ContextItem:createSimple("Foo", {
				getChangedSignal = function(obj)
					getSignalWasCalled = true
					expect(obj).to.equal(data)
					return signal
				end
			})

			local foo = FooItem.new(data)
			expect(getSignalWasCalled).to.equal(true)

			expect(foo._updateSignal).to.be.ok()
			expect(foo._connection).to.be.ok()

			foo:destroy()
		end)
	end)
end