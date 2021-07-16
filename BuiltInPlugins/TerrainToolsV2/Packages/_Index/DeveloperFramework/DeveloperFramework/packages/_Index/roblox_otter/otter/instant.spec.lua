return function()
	local instant = require(script.Parent.instant)

	it("should have the expected APIs", function()
		local goal = instant(5)

		expect(goal).to.be.a("table")
		expect(goal.step).to.be.a("function")
	end)

	it("should immediately complete", function()
		local state = {
			value = 5,
			complete = false,
		}

		local goal = instant(10)
		state = goal:step(state, 1e-3)

		expect(state.value).to.equal(10)
		expect(state.complete).to.equal(true)
	end)

	it("should remove extra values from state", function()
		local state = {
			value = 5,
			complete = false,

			velocity = 7,
			somethingElse = {},
		}

		local goal = instant(10)
		state = goal:step(state, 1e-3)

		expect(state.velocity).to.never.be.ok()
		expect(state.somethingElse).to.never.be.ok()
	end)
end