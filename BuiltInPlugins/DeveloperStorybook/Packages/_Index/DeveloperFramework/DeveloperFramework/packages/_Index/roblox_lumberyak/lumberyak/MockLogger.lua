-- This mock has the same API as the Logger, but none of the calls do anything.
-- Note that MockLogger and Logger can't be parented to each other.

local MockLogger = {}

MockLogger.Levels = {
	Error = "MockError",
	Warning = "MockWarning",
	Info = "MockInfo",
	Debug = "MockDebug",
	Trace = "MockTrace",
	fromString = function()
		return "MockInfo"
	end,
}

MockLogger.__index = MockLogger

function MockLogger.new()
    return setmetatable({}, MockLogger)
end

function MockLogger.setParent()
end

function MockLogger.setContext()
end

function MockLogger.addSink()
end

function MockLogger.error()
end

function MockLogger.warning()
end

function MockLogger.info()
end

function MockLogger.debug()
end

function MockLogger.trace()
end

return MockLogger
