--[[
	Providable helper for sending analytics events and reporting counters.
	Consumers can use this utility as a wrapper for AnalyticsService,
	allowing mock Analytics objects to be made for testing without sending
	actual analytics calls.

	function Analytics.new(props)
		Creates a new Analytics object with the given props.
		Props:
			string Target = The target namespace to send EventStream events to.
				For Studio plugins, this is usually "studio". If no Target is
				provided, this defaults to "studio".
			string Context = The context of the namespace to send EventStream
				events to. This will usually match or reference the name of the plugin.
			bool LogEvents = Whether to log Analytics events to the console.

	function Analytics.mock()
		Creates a mock Analytics object which will do nothing, but provides a
		proxy for every function so that it can be safely used for testing.

	function Analytics:sendEvent(string eventName, table additionalArgs)
		Sends an EventStream event. The additionalArgs table can be used to pass
		more info along with the event itself.

	function Analytics:reportCounter(string counterName, number num = 1)
		Reports number num to the RCity bucket named counterName. Used for
		iterating ephemeral counters.
]]

local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local Library = script.Parent.Parent
local join = require(Library.join)

local Analytics = {}
Analytics.__index = Analytics

function Analytics.new(props)
	assert(type(props) == "table", "Analytics props is expected to be a table.")
	assert(props.Context, "Analytics expected a context string.")

	local self = {
		senders = props.Senders or RbxAnalyticsService,
		logEvents = props.LogEvents,

		target = props.Target or "studio",
		context = props.Context,

		placeId = game.PlaceId,
		userId = StudioService:GetUserId(),
	}
	setmetatable(self, Analytics)

	self.sessionId = self.senders:GetSessionId()
	self.clientId = self.senders:GetClientId()

	return self
end

-- EventStream events handler
function Analytics:sendEventDeferred(eventName, additionalArgs)
	self:logEvent(eventName, additionalArgs)
	local args = join(additionalArgs, {
		studioSid = self.sessionId,
		clientId = self.clientId,
		placeId = self.placeId,
		userId = self.userId,
	})
	self.senders:SendEventDeferred(self.target, self.context, eventName, args)
end

-- RCity Ephemeral Counters handler
function Analytics:reportCounter(counterName, num)
	self:logCounter(counterName, num)
	self.senders:ReportCounter(counterName, num or 1)
end

function Analytics:reportStats(statName, num)
	self:logStats(statName, num)
	self.senders:ReportStats(statName, num)
end

function Analytics:logEvent(eventName, tab)
	if self.logEvents then
		local readableTable = HttpService:JSONEncode(tab)
		print(string.format("Analytics: sendEventDeferred: \"%s\", %s", eventName, readableTable))
	end
end

function Analytics:logCounter(counterName, value)
	if self.logEvents then
		print(string.format("Analytics: reportCounter: \"%s\", %s", counterName, value))
	end
end

function Analytics:logStats(statName, value)
	if self.logEvents then
		print(string.format("Analytics: reportStats: \"%s\", %s", statName, value))
	end
end

function Analytics.mock(props)
	return Analytics.new(join(props, {
		Senders = {
			SendEventDeferred = function()
			end,
			ReportCounter = function()
			end,
			ReportStats = function()
			end,
			GetSessionId = function()
				return 0
			end,
			GetClientId = function()
				return 0
			end,
		}
	}))
end

return Analytics