--[[
	This module creates a crash object that can be sent to Backtrace.
	For information about what are the acceptable fields, see document:
	https://api.backtrace.io/#tag/submit-crash

	BacktraceReport.new()
		While this constructor creates the necessary fields to send up to the server, it's not the intended constructor.

	BacktraceReporter.fromMessageAndStack(errorMessage, errorStack)
		This constructor allows for an easy way to create reports based on the lua error object.
]]

local FFlagDevFrameworkBacktraceReportUser = game:GetFastFlag("DevFrameworkBacktraceReportUser")

local HttpService = game:GetService("HttpService")

local Framework = script.Parent.Parent.Parent
local Cryo = require(Framework.packages.Cryo)
local t = require(Framework.Util.Typecheck.t)

local BacktraceInterfaces = require(script.Parent.BacktraceInterfaces)
local processErrorStack = require(script.Parent.processErrorStack)

local DEFAULT_THREAD_NAME = "default"

local BacktraceReport = {
	IAttributes = BacktraceInterfaces.IAttributes,
	IAnnotations = BacktraceInterfaces.IAnnotations,
}
BacktraceReport.__index = BacktraceReport

local isCli
if FFlagDevFrameworkBacktraceReportUser then
	isCli, _ = pcall(function()
		return game:GetService("ProcessService")
	end)
end

function BacktraceReport.new()
	-- Return a basic report that has all the required fields

	-- os.date can return nil if given an invalid input; this input is always valid
	-- so it is safe to force it to be `any`.
	local date: any = os.date("!*t")

	local self = {
		uuid = HttpService:GenerateGUID(false):lower(),
		timestamp = os.time(date),
		lang = "lua",
		langVersion = "Roblox" .. _VERSION,
		agent = "backtrace-Lua",
		agentVersion = "0.1.0",
		threads = {},
		mainThread = DEFAULT_THREAD_NAME,
		-- Use PlayerId for consistency with C++ CrashReporter
		PlayerId = FFlagDevFrameworkBacktraceReportUser and not isCli and game:GetService("StudioService"):GetUserId() or nil,
	}
	setmetatable(self, BacktraceReport)

	return self
end

function BacktraceReport.fromMessageAndStack(errorMessage, errorStack)
	assert(t.string(errorMessage), "Expected errorMessage to be a string")
	assert(t.string(errorStack), "Expected errorStack to be a string")
	local report = BacktraceReport.new()

	report:addAttributes({
		["error.message"] = errorMessage,
	})

	local stack, sourceCode = processErrorStack(errorStack)
	report:addStackToMainThread(stack)
	report.sourceCode = sourceCode

	return report
end

function BacktraceReport:validate()
	return BacktraceInterfaces.IBacktraceReport(self)
end

function BacktraceReport:addAttributes(newAttributes)
	assert(self.IAttributes(newAttributes), "Expected newAttributes to be a table")
	self.attributes = Cryo.Dictionary.join(self.attributes or {}, newAttributes)
end

function BacktraceReport:addAnnotations(newAnnotations)
	assert(self.IAnnotations(newAnnotations), "Expected newAnnotations to be a table")
	self.annotations = Cryo.Dictionary.join(self.annotations or {}, newAnnotations)
end

function BacktraceReport:addStackToThread(stack, threadName)
	assert(t.table(stack), "Expected stack to be an array of tables")
	assert(t.string(threadName), "Expected threadName to be a string")
	self.threads = Cryo.Dictionary.join(self.threads, {
		[threadName] = {
			name = threadName,
			stack = stack,
		}
	})
end

function BacktraceReport:addStackToMainThread(stack)
	assert(t.table(stack), "Expected stack to be an array of tables")
	self:addStackToThread(stack, self.mainThread)
end

return BacktraceReport
