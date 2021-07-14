return function()
	local Plugin = script.Parent.Parent.Parent
	local Rodux = require(Plugin.Rodux)

	local Notifications = require(script.Parent.Notifications)

	local SetNotification = require(Plugin.SrcDeprecated.Actions.SetNotification)

	local function createTestStore()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(Notifications, nil, middlewares)
		return store
	end

	it("should return a table with the correct members", function()
		local state = Notifications(nil, {})

		expect(type(state)).to.equal("table")
		expect(state.QuantizeWarning).to.be.ok()
		expect(state.Saved).to.be.ok()
		expect(state.Loaded).to.be.ok()
		expect(state.ClippedWarning).to.be.ok()
	end)

	describe("SetNotification", function()
		it("should set the value at the notification key", function()
			local store = createTestStore()

			store:dispatch(SetNotification("QuantizeWarning", true))
			expect(store:getState().QuantizeWarning).to.equal(true)

			store:dispatch(SetNotification("QuantizeWarning", false))
			expect(store:getState().QuantizeWarning).to.equal(false)
		end)

		it("should throw an error if the notification does not exist", function()
			local store = createTestStore()

			expect(function()
				store:dispatch(SetNotification("BadNotification", true))
			end).to.throw()
		end)
	end)
end