return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local Consumer = require(script.Parent.Consumer)
	local ContextItem = require(script.Parent.ContextItem)
	local Provider = require(script.Parent.Provider)
	local provide = require(script.Parent.provide)

	local Util = require(Framework.Util)
	local Signal = Util.Signal

	it("should create and destroy without errors", function()
		local element = Roact.createElement(Consumer, {
			ContextMap = {},
			Render = function()
			end,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should expect a ContextMap prop", function()
		local element = Roact.createElement(Consumer, {
			Render = function()
			end,
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should expect a Render prop", function()
		local element = Roact.createElement(Consumer, {
			ContextMap = {},
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should throw if an item in ContextMap is not a ContextItem", function()
		local element = Roact.createElement(Consumer, {
			ContextMap = {
				Test = "Test",
			},
			Render = function()
			end,
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should throw if an item in ContextMap has no Provider in the tree", function()
		local testItem = ContextItem:extend("TestItem")

		local element = Roact.createElement(Consumer, {
			ContextMap = {
				Test = testItem,
			},
			Render = function()
			end,
		})
		expect(function()
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end).to.throw()
	end)

	it("should pass a map of ContextItems to its render function", function()
		local testItem = ContextItem:extend("TestItem")
		function testItem:createProvider(root)
			return Roact.createElement(Provider, {
				ContextItem = self,
			}, {root})
		end

		local foundItem

		local tree = provide({testItem}, {
			Consumer = Roact.createElement(Consumer, {
				ContextMap = {
					Test = testItem,
				},
				Render = function(items)
					foundItem = items.Test
				end,
			})
		})
		local instance = Roact.mount(tree)
		Roact.unmount(instance)

		expect(foundItem).to.be.ok()
	end)

	it("should re-render when the ContextItem update signal fires", function()
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

		local numRenders = 0

		local tree = provide({testItem}, {
			Consumer = Roact.createElement(Consumer, {
				ContextMap = {
					Test = testItem,
				},
				Render = function()
					numRenders = numRenders + 1
				end,
			})
		})
		local instance = Roact.mount(tree)

		expect(numRenders).to.equal(1)
		testItem:fireUpdate()
		expect(numRenders).to.equal(2)

		Roact.unmount(instance)
	end)
end