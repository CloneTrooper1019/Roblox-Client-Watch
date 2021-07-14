--[[
	Specialized reporter for sending data to Backtrace. Useful for reporting Lua errors.

	function BacktraceReporter.new(optional table props):
		Constructs a new BacktraceReporter. Requires an accessToken issued by Backtrace.
		This also starts the timers for the automatic error report queue.

	function BacktraceReporter:sendErrorReport(BacktraceReport report, string log):
		Sends a BacktraceReport to the server. If a log is provided, it will report it as well.

	function BacktraceReporter:reportErrorImmediately(string errorMessage, string errorStack, string details):
		Takes the information from the ScriptContext.ErrorDetailed signal and creates a Backtrace report.
		Then sends the report immediately.

	function BacktraceReporter:reportErrorDeferred(string errorMessage, string errorStack, string details):
		Takes the information from the ScriptContext.ErrorDetailed signal and creates a Backtrace report.
		This report is queued up and sent at a later time, based on the configuration of the ErrorQueue.

	function BacktraceReporter:updateSharedAttributes(dictionary newAttributes):
		Attaches additional Backtrace Attributes that will be included with every report.

	function BacktraceReporter:updateSharedAnnotations(newAnnotations)
		Attaches additional Backtrace Annotations that will be  included with every report.

	function BacktraceReporter:reportAllErrors()
		This function will flush the ErrorQueue if any errors haven't been reported yet.

	function BacktraceReporter:stop()
		This function stops the internal timers that decide when to report errors.
		Calling this will also flush all of the errors still in the queue.

]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Framework = script.Parent.Parent.Parent
local Util = Framework.Util
local Cryo = require(Util.Cryo)
local BacktraceInterfaces = require(script.Parent.BacktraceInterfaces)
local BacktraceReport = require(script.Parent.BacktraceReport)
local ErrorQueue = require(script.Parent.Parent.ErrorQueue)
local Url = require(Framework.RobloxAPI.Url)

local IAnnotations = BacktraceReport.IAnnotations
local IAttributes = BacktraceReport.IAttributes

local DEVELOPMENT_IN_STUDIO = RunService:IsStudio()
local DEFAULT_LOG_INTERVAL_SECONDS = 10


local BacktraceReporter = {}
BacktraceReporter.__index = BacktraceReporter

function BacktraceReporter.new(props)
	assert(BacktraceInterfaces.IBacktraceReporter(props))
	assert(#props.accessToken > 0, "Expected accessToken to be a non-empty string")
	local self = {
		_errorQueue = nil,
		_networking = props.networking,
		_accessToken = props.accessToken,

		_processErrorReportMethod = props.processErrorReportMethod,
		_generateLogMethod = props.generateLogMethod,
		
		_sharedAttributes = {},
		_sharedAnnotations = {},
		
		_logIntervalInSeconds = props.logIntervalInSeconds or DEFAULT_LOG_INTERVAL_SECONDS,
		_lastLogTime = 0,
		_isEnabled = true,
	}
	setmetatable(self, BacktraceReporter)

	-- Create and start the ErrorQueue for deferred reports.
	self._errorQueue = ErrorQueue.new(function(_, errorData, errorCount)
		local log = errorData.log
		local errorReport = errorData.backtraceReport
		errorReport:addAttributes({
			ErrorCount = errorCount,
		})

		self:sendErrorReport(errorReport, log)
	end, props.queueOptions)

	if not _G.__TESTEZ_RUNNING_TEST__ then
		self._errorQueue:startTimer()
	end

	return self
end

function BacktraceReporter:getUploadUrl(argMap)
	return Url.composeUrl("https://upload.crashes.rbxinfra.com", "post", Cryo.Dictionary.join({
		token = self._accessToken,
	}, argMap))
end

function BacktraceReporter:sendErrorReport(report, log)
	-- Validating the report can be slow;
	-- And an invalid report might still be able to be processed, sent, and accepted by Backtrace.
	-- So we don't validate reports in production.
	if _G.__TESTEZ_RUNNING_TEST__ then
		assert(report:validate())
	end

	local encodeSuccess, jsonData = pcall(function()
		return HttpService:JSONEncode(report)
	end)

	if not encodeSuccess then
		warn("Cannot convert report to JSON")
		return
	end


	local targetUrl = self:getUploadUrl({ format = "json" })
	local headers = {
		["Content-Type"] = "application/json",
	}

	local requestPromise = self._networking:post(targetUrl, jsonData, headers)
	requestPromise = self._networking:parseJson(requestPromise)
	requestPromise:andThen(function(response)
		if type(log) ~= "string" or #log == 0 then
			return
		end

		-- Be aware that even when a response is 200, the report
		-- might still be rejected/deleted by Backtrace after it is received.
		local rxid = response.responseBody._rxid
		if rxid == nil then
			return
		end

		local targetUrl = self:getUploadUrl({
			object = rxid,
			attachment_name = "log.txt",
		})
		local headers = {
			["Content-Type"] = "text/plain",
		}

		local requestPromise = self._networking:post(targetUrl, log, headers)
		requestPromise:catch(function(err)
			-- We have no use for the result of this request right now, but catch any errors that are thrown
			warn("Failed to report a log with message : ", tostring(err))
		end)
	end):catch(function(err)
		warn("Failed to send a report with message : ", tostring(err))
	end)
end

function BacktraceReporter:_generateLog()
	local enoughTimeHasPassed = tick() - self._lastLogTime > self._logIntervalInSeconds
	if self._generateLogMethod ~= nil and enoughTimeHasPassed then
		self._lastLogTime = tick()

		local success, log = pcall(self._generateLogMethod)
		if success and type(log) == "string" and #log > 0 then
			return log
		end
	end

	return nil
end

function BacktraceReporter:_generateErrorReport(errorMessage, errorStack, details)
	local report = BacktraceReport.fromMessageAndStack(errorMessage, errorStack)
	report:addAttributes(self._sharedAttributes)
	report:addAnnotations(self._sharedAnnotations)

	if type(details) == "string" and details ~= "" then
		report:addAnnotations({
			["stackDetails"] = details,
		})
	end

	return report
end

-- Immediate reports
-- You most likely should not use this. Use reportErrorDeferred instead.
function BacktraceReporter:reportErrorImmediately(errorMessage, errorStack, details)
	if not self._isEnabled then
		return
	end

	local newReport = self:_generateErrorReport(errorMessage, errorStack, details)
	if self._processErrorReportMethod ~= nil then
		newReport = self._processErrorReportMethod(newReport)
	end

	local log = self:_generateLog()

	self:sendErrorReport(newReport, log)
end

-- Deferred reports using an error queue
function BacktraceReporter:reportErrorDeferred(errorMessage, errorStack, details)
	if not self._isEnabled then
		return
	end

	local errorKey = string.format("%s | %s", errorMessage, errorStack)
	local errorData = {}

	-- If this error is a new one, we want a full report on it.
	-- Similar errors following this one will be squashed in the queue and share report with this one
	-- before they're flushed out and reported.
	if not self._errorQueue:hasError(errorKey) then
		local newReport = self:_generateErrorReport(errorMessage, errorStack, details)

		if self._processErrorReportMethod ~= nil then
			newReport = self._processErrorReportMethod(newReport)
		end

		errorData = {
			backtraceReport = newReport,
			log = self:_generateLog(),
		}
	end

	self._errorQueue:addError(errorKey, errorData)
end

-- API for updating shared attributes/annotations
function BacktraceReporter:updateSharedAttributes(newAttributes)
	-- Merge with current one first. This allows usage of Cryo.None.
	local mergedAttributes = Cryo.Dictionary.join(self._sharedAttributes, newAttributes)

	-- Validate the merged result, and only update if it's valid.
	local valid, message = IAttributes(mergedAttributes)
	if not valid then
		if _G.__TESTEZ_RUNNING_TEST__ then
			assert(valid, message)
		else
			return
		end
	end

	self._sharedAttributes = mergedAttributes
end

function BacktraceReporter:updateSharedAnnotations(newAnnotations)
	-- Although annotations can be nested tables, this is not a recursive merge.
	local mergedAnnotations = Cryo.Dictionary.join(self._sharedAnnotations, newAnnotations)

	local valid, message = IAnnotations(mergedAnnotations)
	if not valid then
		if DEVELOPMENT_IN_STUDIO or _G.__TESTEZ_RUNNING_TEST__ then
			assert(valid, message)
		else
			return
		end
	end

	self._sharedAnnotations = mergedAnnotations
end

-- Flush all reports in the queue.
function BacktraceReporter:reportAllErrors()
	if self._errorQueue ~= nil then
		self._errorQueue:reportAllErrors()
	end
end

function BacktraceReporter:stop()
	self._isEnabled = false

	if self._errorQueue ~= nil then
		self._errorQueue:stopTimer()
	end
end

return BacktraceReporter
