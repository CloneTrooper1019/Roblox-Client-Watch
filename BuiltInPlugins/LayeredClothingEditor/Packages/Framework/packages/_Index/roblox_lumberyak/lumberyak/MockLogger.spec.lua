return function()
	local MockLogger = require(script.Parent.MockLogger)
	local Logger = require(script.Parent.Logger)

	it("MockLogger should have the same API as Logger", function()
		for k, v in pairs(Logger) do
			local mock = MockLogger[k]
			assert(mock, "Expected a mock of " .. k)
			assert(type(mock) == type(v),
				"Expected the type of " .. k .. " to be " .. type(v) .. ", got " .. type(mock))
		end
	end)

	it("MockLogger.Levels should have the same API as Logger.Levels", function()
		for k, v in pairs(Logger.Levels) do
			local mock = MockLogger.Levels[k]
			assert(mock, "Expected a mock of " .. k)
			assert(type(mock) == type(v),
				"Expected the type of " .. k .. " to be " .. type(v) .. ", got " .. type(mock))
		end
	end)
end