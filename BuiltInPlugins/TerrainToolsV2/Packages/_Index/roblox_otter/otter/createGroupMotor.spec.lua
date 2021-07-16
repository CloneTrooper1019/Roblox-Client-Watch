return function()
	local validateMotor = require(script.Parent.validateMotor)
	local createSpy = require(script.Parent.createSpy)

	local createGroupMotor = require(script.Parent.createGroupMotor)

	-- test motion object that completes after step has been called numSteps times
	local function createStepper(numSteps)
		local self = {
			stepCount = 0,
		}

		self.step = function(_, state, dt)
			self.stepCount = self.stepCount + 1

			if self.stepCount >= numSteps then
				return {
					value = state.value,
					velocity = state.velocity,
					complete = true,
				}
			end

			return state
		end

		setmetatable(self, {
			__index = function(_, key)
				error(("%q is not a valid member of stepper"):format(key))
			end,
		})

		return self
	end

	it("should be a valid motor", function()
		local motor = createGroupMotor({})
		validateMotor(motor)
		motor:destroy()
	end)

	describe("onStep", function()
		it("should not be called initially", function()
			local motor = createGroupMotor({
				x = 0,
			})

			local spy = createSpy()
			motor:onStep(spy.value)

			motor:setGoal({
				x = createStepper(5),
			})

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)
	end)

	describe("setGoal", function()
		it("should work as intended in onComplete callbacks", function()
			local motor = createGroupMotor({
				x = 0,
			})

			local spy = createSpy(function()
				motor:setGoal({ x = createStepper(3), })
			end)

			motor:onComplete(spy.value)

			motor:setGoal({ x = createStepper(3), })

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(1)
			--make sure the motor continues to run after calling setGoal in onComplete
			expect(motor.__running).to.equal(true)

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(2)
			expect(motor.__running).to.equal(true)

			motor:destroy()
		end)
	end)

	describe("onComplete should be called when", function()
		it("has completed its motion", function()
			local motor = createGroupMotor({
				x = 0,
			})

			motor:setGoal({
				x = createStepper(5),
			})

			local spy = createSpy()

			motor:onComplete(spy.value)

			for _ = 1, 5 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(1)

			motor:destroy()
		end)

		it("has multiple atributes in motion", function()
			local motor = createGroupMotor({
				x = 0,
				y = 10,
			})

			motor:setGoal({
				x = createStepper(2),
				y = createStepper(5),
			})

			local spy = createSpy()

			motor:onComplete(spy.value)

			for _ = 1, 2 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(0)

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(1)

			motor:destroy()
		end)

		it("has restarted its motion", function()
			local motor = createGroupMotor({
				x = 0,
			})

			motor:setGoal({
				x = createStepper(3),
			})

			local spy = createSpy()

			motor:onComplete(spy.value)

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(1)

			motor:setGoal({
				x = createStepper(3),
			})

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(2)

			motor:destroy()
		end)
	end)

	describe("onComplete should not be called when", function()
		it("has no goals set", function()
			local motor = createGroupMotor({
				x = 2,
			})

			local spy = createSpy()
			motor:onComplete(spy.value)

			for _ = 1, 3 do
				motor:step(1)
			end

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)

		it("has not completed motion", function()
			local motor = createGroupMotor({
				x = 0,
			})

			motor:setGoal({
				x = createStepper(2),
			})

			local spy = createSpy()
			motor:onComplete(spy.value)

			motor:step(1)

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)

		it("has one non-completed motion", function()
			local motor = createGroupMotor({
				x = 0,
				y = 0,
			})

			motor:setGoal({
				x = createStepper(0),
				y = createStepper(2),
			})

			local spy = createSpy()
			motor:onComplete(spy.value)

			motor:step(1)

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)

		it("does not call step", function()
			local motor = createGroupMotor({
				x = 0,
			})

			motor:setGoal({
				x = createStepper(0),
			})

			local spy = createSpy()
			motor:onComplete(spy.value)

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)

		it("is stopped in onStep", function()
			local motor = createGroupMotor({
				x = 0,
			})

			motor:setGoal({
				x = createStepper(1),
			})

			local spy = createSpy()
			motor:onComplete(spy.value)
			motor:onStep(function() motor:stop() end)

			motor:step(1)

			expect(spy.callCount).to.equal(0)

			motor:destroy()
		end)
	end)
end