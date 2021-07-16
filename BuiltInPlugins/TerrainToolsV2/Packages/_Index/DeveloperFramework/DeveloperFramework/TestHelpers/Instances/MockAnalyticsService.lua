local MockAnalyticsService = {}
MockAnalyticsService.__index = MockAnalyticsService

function MockAnalyticsService.new()
	local self = setmetatable({
		eventCount = 0,
		lastEvent = nil,

		_sessionId = "",
	}, MockAnalyticsService)

	return self
end

function MockAnalyticsService:Destroy()
end

function MockAnalyticsService:GetSessionId()
	return self._sessionId
end

function MockAnalyticsService:SendEventDeferred(target, context, evt, argsTable)
	local event = {
		target = target,
		ctx = context,
		evt = evt,
	}

	assert(type(argsTable) == "table", "expected table, argsTable was " .. type(argsTable))
	for k, v in pairs(argsTable) do
		if event[k] ~= nil then
			warn("Overriding base keyword " .. k .. " in via argsTable in SendEventDeferred()." )
		end
		event[k] = v
	end

	self.lastEvent = event
	self.eventCount = self.eventCount + 1
end

return MockAnalyticsService
