return function()
	local Roact = require(script.Parent.Parent.Roact)
	local Rodux = require(script.Parent.Parent.Rodux)

	local StoreProvider = require(script.Parent.StoreProvider)

	local getStore = require(script.Parent.getStore)

	it("should return the store when present", function()
		local function reducer()
			return 0
		end

		local store = Rodux.Store.new(reducer)
		local consumedStore = nil

		local StoreConsumer = Roact.Component:extend("StoreConsumer")

		function StoreConsumer:init()
			consumedStore = getStore(self)
		end

		function StoreConsumer:render()
			return nil
		end

		local tree = Roact.createElement(StoreProvider, {
			store = store,
		}, {
			Consumer = Roact.createElement(StoreConsumer),
		})

		local handle = Roact.mount(tree)

		expect(consumedStore).to.equal(store)

		Roact.unmount(handle)
		store:destruct()
	end)

	it("should return nil when the store is not present", function()
		-- Use a non-nil value to know for sure if StoreConsumer:init was called
		local consumedStore = 6

		local StoreConsumer = Roact.Component:extend("StoreConsumer")

		function StoreConsumer:init()
			consumedStore = getStore(self)
		end

		function StoreConsumer:render()
			return nil
		end

		local tree = Roact.createElement(StoreConsumer)
		local handle = Roact.mount(tree)

		expect(consumedStore).to.equal(nil)

		Roact.unmount(handle)
	end)
end