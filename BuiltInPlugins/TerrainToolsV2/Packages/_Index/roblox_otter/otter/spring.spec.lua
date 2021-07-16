return function()
	local spring = require(script.Parent.spring)

	it("should have all expected APIs", function()
		expect(spring).to.be.a("function")

		local s = spring(1, {
			dampingRatio = 0.1,
			frequency = 10,
			restingVelocityLimit = 0.1,
			restingPositionLimit = 0.01,
		})

		expect(s).to.be.a("table")
		expect(s.step).to.be.a("function")

		-- handle when spring lacks option table
		s = spring(1)

		expect(s).to.be.a("table")
		expect(s.step).to.be.a("function")
	end)

	it("should handle being still correctly", function()
		local s = spring(1, {
			dampingRatio = 0.1,
			frequency = 10,
			restingVelocityLimit = 0.1,
			restingPositionLimit = 0.01,
		})

		local state = s:step({
			value = 1,
			velocity = 0,
			complete = false,
		}, 1)

		expect(state.value).to.equal(1)
		expect(state.velocity).to.equal(0)
		expect(state.complete).to.equal(true)
	end)

	it("should return not complete when in motion", function()
		local goal = spring(100, {
			dampingRatio = 0.1,
			frequency = 10,
		})

		local state = {
			value = 1,
			velocity = 0,
			complete = false,
		}

		state = goal:step(state, 1e-3)

		expect(state.value < 100).to.equal(true)
		expect(state.velocity > 0).to.equal(true)
		expect(state.complete).to.equal(false)
	end)

	describe("should eventaully complete when", function()
		it("is critically damped", function()
			local s = spring(3, {
				dampingRatio = 1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(3)
			expect(state.velocity).to.equal(0)
		end)

		it("is over damped", function()
			local s = spring(3, {
				dampingRatio = 10,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(3)
			expect(state.velocity).to.equal(0)
		end)

		it("is under damped", function()
			local s = spring(3, {
				dampingRatio = 0.1,
				frequency = 0.5,
			})

			local state = {
				value = 1,
				velocity = 0,
				complete = false,
			}

			while not state.complete do
				state = s:step(state, 0.5)
			end

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(3)
			expect(state.velocity).to.equal(0)
		end)
	end)

	describe("should handle infinite time deltas when", function()
		-- TODO: This test is broken.
		itSKIP("is critically damped", function()
			local s = spring(20, {
				dampingRatio = 1,
				frequency = 1,
			})

			local state = {
				value = -10,
				velocity = 0,
				complete = false,
			}
			state = s:step(state, math.huge)

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(20)
			expect(state.velocity).to.equal(0)
		end)

		-- TODO: This test is broken.
		itSKIP("is underdamped", function()
			local s = spring(20, {
				dampingRatio = 0.5,
				frequency = 1,
			})

			local state = {
				value = -10,
				velocity = 0,
				complete = false,
			}
			state = s:step(state, math.huge)

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(20)
			expect(state.velocity).to.equal(0)
		end)

		it("is overdamped", function()
			local s = spring(20, {
				dampingRatio = 2,
				frequency = 1,
			})

			local state = {
				value = -10,
				velocity = 0,
				complete = false,
			}
			state = s:step(state, math.huge)

			expect(state.complete).to.equal(true)
			expect(state.value).to.equal(20)
			expect(state.velocity).to.equal(0)
		end)
	end)

	it("should remain complete when completed", function()
		local s = spring(3, {
			dampingRatio = 1,
			frequency = 0.5,
		})

		local state = {
			value = 1,
			velocity = 0,
			complete = false,
		}

		while not state.complete do
			state = s:step(state, 0.5)
		end
		state = s:step(state, 0.5)

		expect(state.complete).to.equal(true)
		expect(state.value).to.equal(3)
		expect(state.velocity).to.equal(0)
	end)
end
