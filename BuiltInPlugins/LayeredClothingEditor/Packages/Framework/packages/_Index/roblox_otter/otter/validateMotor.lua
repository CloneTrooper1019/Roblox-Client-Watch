local function validateMotor(motor)
	assert(typeof(motor) == "table")
	assert(typeof(motor.start) == "function")
	assert(typeof(motor.stop) == "function")
	assert(typeof(motor.step) == "function")
	assert(typeof(motor.setGoal) == "function")
	assert(typeof(motor.onStep) == "function")
	assert(typeof(motor.onComplete) == "function")
	assert(typeof(motor.destroy) == "function")
end

return validateMotor