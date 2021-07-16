local RunService = game:GetService("RunService")

local assign = require(script.Parent.assign)
local createSignal = require(script.Parent.createSignal)

local GroupMotor = {}
GroupMotor.prototype = {}
GroupMotor.__index = GroupMotor.prototype

local function createGroupMotor(initialValues)
	assert(typeof(initialValues) == "table")

	local states = {}

	for key, value in pairs(initialValues) do
		states[key] = {
			value = value,
			complete = true,
		}
	end

	local self = {
		__goals = {},
		__states = states,
		__allComplete = true,
		__onComplete = createSignal(),
		__onStep = createSignal(),
		__running = false,
	}

	setmetatable(self, GroupMotor)

	return self
end

function GroupMotor.prototype:start()
	if self.__running then
		return
	end

	self.__connection = RunService.Heartbeat:Connect(function(dt)
		self:step(dt)
	end)

	self.__running = true
end

function GroupMotor.prototype:stop()
	if self.__connection ~= nil then
		self.__connection:Disconnect()
		self.__running = false
	end
end

function GroupMotor.prototype:step(dt)
	assert(typeof(dt) == "number")

	if self.__allComplete then
		return
	end

	local allComplete = true
	local values = {}

	for key, state in pairs(self.__states) do
		if not state.complete then
			local goal = self.__goals[key]

			if goal ~= nil then
				local maybeNewState = goal:step(state, dt)

				if maybeNewState ~= nil then
					state = maybeNewState
					self.__states[key] = maybeNewState
				end
			else
				state.complete = true
			end

			if not state.complete then
				allComplete = false
			end
		end

		values[key] = state.value
	end

	local wasAllComplete = self.__allComplete
	self.__allComplete = allComplete

	self.__onStep:fire(values)

	-- Check self.__allComplete as the motor may have been restarted in the onStep callback
	-- even if allComplete is true.
	-- Check self.__running in case the motor was stopped by onStep
	if self.__allComplete and not wasAllComplete and self.__running then
		self:stop()
		self.__onComplete:fire(values)
	end
end

function GroupMotor.prototype:setGoal(goals)
	assert(typeof(goals) == "table")

	self.__goals = assign({}, self.__goals, goals)

	for key in pairs(goals) do
		local state = self.__states[key]

		if state == nil then
			error(("Cannot set goal for the value %s because it doesn't exist"):format(tostring(key)), 2)
		end

		state.complete = false
	end

	self.__allComplete = false
	self:start()
end

function GroupMotor.prototype:onStep(callback)
	assert(typeof(callback) == "function")

	return self.__onStep:subscribe(callback)
end

function GroupMotor.prototype:onComplete(callback)
	assert(typeof(callback) == "function")

	return self.__onComplete:subscribe(callback)
end

function GroupMotor.prototype:destroy()
	self:stop()
end

return createGroupMotor
