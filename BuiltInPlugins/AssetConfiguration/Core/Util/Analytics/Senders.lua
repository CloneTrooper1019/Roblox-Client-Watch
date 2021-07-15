local Plugin = script.Parent.Parent.Parent.Parent

local AnalyticsLogs = require(Plugin.Core.Util.Analytics.Logs)
local sendResultToKibana = require(Plugin.Libs.Framework.Util.sendResultToKibana)

local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local FFlagNewPackageAnalyticsWithRefactor2 = game:GetFastFlag("NewPackageAnalyticsWithRefactor2")
local FFlagInfluxReportingPackageAnalyticsHundrethsPercent = game:GetFastInt("InfluxReportingPackageAnalyticsHundrethsPercent")

local function makeSettingName(counter)
	return "ToolboxAnalytics_" .. counter
end

local counters = {}

local Senders = {}

function Senders.sendEventImmediately(target, context, name, args)
	AnalyticsLogs.logAnalytics("sendEventImmediately", target, context, name, args)
	RbxAnalyticsService:SendEventImmediately(target, context, name, args)
end

function Senders.sendEventDeferred(target, context, name, args)
	AnalyticsLogs.logAnalytics("sendEventDeferred", target, context, name, args)
	RbxAnalyticsService:SendEventDeferred(target, context, name, args)
end

function Senders.trackEvent(category, action, label, value)
	AnalyticsLogs.logEvent("trackEvent", category, action, label, value)
	RbxAnalyticsService:TrackEvent(category, action, label, value)
end

function Senders.trackEventWithArgs(category, action, label, argTable, value)
	AnalyticsLogs.logEvent("trackEventWithArgs", category, action, label, value)
	RbxAnalyticsService:TrackEventWithArgs(category, action, label, argTable, value)
end

function Senders.reportCounter(counter, amount)
	amount = amount or 1
	AnalyticsLogs.logCounterEvent("reportCounter", counter, amount)
	RbxAnalyticsService:ReportCounter(counter, amount)
end

function Senders.incrementCounter(counter, amount)
	amount = amount or 1
	AnalyticsLogs.logCounterEvent("incrementCounter", counter, amount)
	if counters[counter] then
		counters[counter] = counters[counter] + amount
	else
		counters[counter] = amount
	end
end

function Senders.sendResultToKibana(result)
	assert(FFlagNewPackageAnalyticsWithRefactor2)
	sendResultToKibana(result)
end

function Senders.sendReports(plugin)
	local userId = plugin:GetStudioUserId()
	AnalyticsLogs.logSendReports(userId)

	for counter, value in pairs(counters) do
		-- TODO CLIDEVSRVS-1689: In Studio, this gets it from the registry
		-- We can't do that in Lua so using plugin settings instead
		-- This is limited to just this plugin though
		local settingsValue = plugin:GetSetting(makeSettingName(counter)) or 0
		local reportValue = value + settingsValue
		plugin:SetSetting(makeSettingName(counter), reportValue)

		AnalyticsLogs.logReport(counter, value, reportValue)

		counters[counter] = 0

		Senders.trackEvent("UsageFeatures", counter, userId, reportValue)
	end
end

return Senders
