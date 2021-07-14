return function()
	local Plugin = script.Parent.Parent.Parent

	local SetControlsPanelBlockerActivity = require(Plugin.Src.Actions.SetControlsPanelBlockerActivity)
	local SetControlsPanelBlockerMessage = require(Plugin.Src.Actions.SetControlsPanelBlockerMessage)

	local ControlsPanelBlocker = require(Plugin.Src.Reducers.ControlsPanelBlocker)

	local function createDefaultState()
		return ControlsPanelBlocker(nil,{})
	end

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.isActive).to.equal(false)
		expect(state.message).to.equal("")
	end)

	describe("SetControlsPanelBlockerActivity action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = ControlsPanelBlocker(state, SetControlsPanelBlockerActivity(true))

			expect(state.isActive).to.be.ok()
			expect(state.isActive).to.equal(true)
		end)
	end)

	describe("SetControlsPanelBlockerMessage action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = ControlsPanelBlocker(state, SetControlsPanelBlockerMessage("test"))

			expect(state.message).to.be.ok()
			expect(state.message).to.equal("test")
		end)
	end)
end