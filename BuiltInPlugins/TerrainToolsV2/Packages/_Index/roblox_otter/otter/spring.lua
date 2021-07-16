--[[
	An analytical spring solution as a function of damping ratio and frequency.

	Adapted from
	https://gist.github.com/Fraktality/1033625223e13c01aa7144abe4aaf54d
]]

local assign = require(script.Parent.assign)

local pi = math.pi
local abs = math.abs
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local DEFAULT_RESTING_VELOCITY_LIMIT = 1e-3
local DEFAULT_RESTING_POSITION_LIMIT = 1e-2

local function step(self, state, dt)
	-- Advance the spring simulation by dt seconds.
	-- Take the damped harmonic oscillator ODE:
	--    f^2*(X[t] - g) + 2*d*f*X'[t] + X''[t] = 0
	-- Where X[t] is position at time t, g is desired position, f is angular frequency, and d is damping ratio.
	-- Apply constant initial conditions:
	--    X[0] = p0
	--    X'[0] = v0
	-- Solve the IVP to get analytic expressions for X[t] and X'[t].
	-- The solution takes on one of three forms for d=1, d<1, and d>1

	local d = self.__dampingRatio
	local f = self.__frequency * 2 * pi -- Rad/s
	local g = self.__goalPosition
	local velLimit = self.__restingVelocityLimit
	local posLimit = self.__restingPositionLimit

	local p0 = state.value
	local v0 = state.velocity or 0

	local offset = p0 - g
	local decay = exp(-dt*d*f)

	local p1, v1

	if d == 1 then -- Critically damped
		p1 = (v0*dt + offset*(f*dt + 1))*decay + g
		v1 = (v0 - f*dt*(offset*f + v0))*decay

	elseif d < 1 then -- Underdamped
		local c = sqrt(1 - d*d)

		local i = cos(f*c*dt)
		local j = sin(f*c*dt)

		-- Problem: Damping ratios close to 1 can cause numerical instability.
		-- Solution: Rearrange to group terms involving j/c, then find an approximation z for j/c.
		--    z = sin(dt*f*c)/c
		-- Substitute a for dt*f
		--    z = sin(a*c)/c
		-- Take the 5th-order series expansion of z at c = 0
		--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
		--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
		-- Rewrite in Horner form to mitigate precision issues
		--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

		local z
		if c > 1e-4 then
			z = j/c
		else
			local a = dt*f
			z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
		end

		-- Repeat the process with a->dt and c->b=f*c for the f->0 case
		local y
		if f*c > 1e-4 then
			y = j/(f*c)
		else
			local b = f*c
			y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
		end

		p1 = (offset*(i + d*z) + v0*y)*decay + g
		v1 = (v0*(i - z*d) - offset*(z*f))*decay

	else -- Overdamped
		local c = sqrt(d*d - 1)

		local r1 = -f*(d - c)
		local r2 = -f*(d + c)

		local co2 = (v0 - r1*offset)/(2*f*c)
		local co1 = offset - co2

		local e1 = co1*exp(r1*dt)
		local e2 = co2*exp(r2*dt)

		p1 = e1 + e2 + g
		v1 = r1*e1 + r2*e2
	end

	local positionOffset = abs(p1 - self.__goalPosition)
	local velocityOffset = abs(v1)

	local complete = velocityOffset < velLimit and positionOffset < posLimit

	if complete then
		p1 = self.__goalPosition
		v1 = 0
	end

	return {
		value = p1,
		velocity = v1,
		complete = complete,
	}
end

local function spring(goalPosition, inputOptions)
	assert(typeof(goalPosition) == "number")

	local options = {
		dampingRatio = 1,
		frequency = 1,
		restingVelocityLimit = DEFAULT_RESTING_VELOCITY_LIMIT,
		restingPositionLimit = DEFAULT_RESTING_POSITION_LIMIT,
	}

	if inputOptions ~= nil then
		assert(typeof(inputOptions) == "table")
		assign(options, inputOptions)
	end

	local dampingRatio = options.dampingRatio
	local frequency = options.frequency
	local restingVelocityLimit = options.restingVelocityLimit
	local restingPositionLimit = options.restingPositionLimit

	assert(typeof(dampingRatio) == "number")
	assert(typeof(frequency) == "number")
	assert(typeof(restingVelocityLimit) == "number")
	assert(typeof(restingPositionLimit) == "number")

	assert(restingVelocityLimit >= 0, "Expected restingVelocityLimit >= 0")
	assert(restingPositionLimit >= 0, "Expected restingPositionLimit >= 0")

	local self = {
		__dampingRatio = dampingRatio,
		__frequency = frequency, -- Hz
		__restingVelocityLimit = restingVelocityLimit,
		__restingPositionLimit = restingPositionLimit,
		__goalPosition = goalPosition,
		step = step,
	}

	return self
end

return spring
