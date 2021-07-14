return function()
	local HttpService = game:GetService("HttpService")

	local BacktraceReporter = require(script.Parent.BacktraceReporter)
	local BacktraceReport = require(script.Parent.BacktraceReport)

	local Framework = script.Parent.Parent.Parent
	local Util = Framework.Util
	local Cryo = require(Util.Cryo)
	local deepEqual = require(Util.deepEqual)
	local Networking = require(Framework.Http).Networking

	local mockErrorMessage = "index nil"
	local mockErrorStack = "Script 'Workspace.Script', Line 3"
	local requestBodySuccess = {
		Body = HttpService:JSONEncode({ _rxid = 12345 }),
		Success = true,
		StatusMessage = "OK",
		StatusCode = 200,
	}

	local function createMockNetworking(onRequest)
		if not onRequest then
			onRequest = function(requestObj)
				return requestBodySuccess
			end
		end

		return Networking.mock({
			onRequest = onRequest,
		})
	end

	describe("new()", function()
		it("should error if no networking or token is passed in", function()
			expect(function()
				BacktraceReporter.new({})
			end).to.throw()

			expect(function()
				BacktraceReporter.new({
					networking = createMockNetworking(),
					accessToken = nil,
				})
			end).to.throw()

			expect(function()
				BacktraceReporter.new({
					networking = nil,
					accessToken = "12345",
				})
			end).to.throw()
		end)

		it("should construct with proper inputs", function()
			local reporter = BacktraceReporter.new({
				networking = createMockNetworking(),
				accessToken = "12345",
			})
			expect(reporter).to.be.ok()
		end)
	end)

	describe("sendErrorReport()", function()
		local requestsSent
		local reporter
		local requestBody
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					local success, result = pcall(HttpService.JSONDecode, HttpService, requestObj.Body)
					if success then
						requestBody = result
					end
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
		end)

		it("should send error report", function()
			local report = BacktraceReport.new()

			reporter:sendErrorReport(report)
			expect(requestsSent).to.equal(1)

			reporter:sendErrorReport(report)
			expect(requestsSent).to.equal(2)
		end)

		it("should assert if the error report is not valid", function()
			local errorReport = {
				error = "random",
			}

			expect(function()
				reporter:sendErrorReport(errorReport)
			end).to.throw()
			expect(requestsSent).to.equal(0)
		end)

		it("should send an error with an expected format", function()
			local testErr = "Attempted to index 'foo' on nil"
			local testStack = table.concat({
				"a.b.c.d.e.SomeComponent, line 98 - field testError",
				"a.b.c.d.e.SomeComponent, line 111 - field foo",
				"a.b.c.Packages._Index.roact.roact.SingleEventManager, line 83"
			}, "\n")
			local report = BacktraceReport.fromMessageAndStack(testErr, testStack)

			reporter:sendErrorReport(report)
			expect(requestsSent).to.equal(1)
			expect(requestBody.uuid).to.be.ok()
			expect(requestBody.timestamp).to.be.ok()
			expect(requestBody.lang).to.equal("lua")
			expect(requestBody.langVersion).to.equal("Roblox" .. _VERSION)
			expect(requestBody.agent).to.equal("backtrace-Lua")
			expect(requestBody.agentVersion).to.be.ok()
			expect(requestBody.threads).to.be.ok()
			expect(requestBody.mainThread).to.be.ok()

			-- check that the error was reported
			expect(requestBody.attributes["error.message"]).to.equal("Attempted to index 'foo' on nil")

			-- check that the list of files is preserved
			expect(requestBody.sourceCode).to.be.ok()
			expect(requestBody.sourceCode["1"].path).to.equal("a.b.c.d.e.SomeComponent")
			expect(requestBody.sourceCode["2"].path).to.equal("a.b.c.Packages._Index.roact.roact.SingleEventManager")
			
			-- check that the error stack is preserved and references the source code
			expect(requestBody.threads["default"]).to.be.ok()
			local errorThread = requestBody.threads["default"]
			expect(errorThread.name).to.equal("default")
			expect(type(errorThread.stack)).to.equal("table")
			expect(#errorThread.stack).to.equal(3)
			expect(errorThread.stack[1].sourceCode).to.equal("1") -- "a.b.c.d.e.SomeComponent"
			expect(errorThread.stack[1].funcName).to.equal("field testError")
			expect(errorThread.stack[1].line).to.equal("98")
			expect(errorThread.stack[2].sourceCode).to.equal("1")
			expect(errorThread.stack[2].funcName).to.equal("field foo")
			expect(errorThread.stack[2].line).to.equal("111")
			expect(errorThread.stack[3].sourceCode).to.equal("2")
			expect(errorThread.stack[3].funcName).to.equal("SingleEventManager")
			expect(errorThread.stack[3].line).to.equal("83")
		end)
	end)

	describe("reportErrorImmediately()", function()
		local requestsSent
		local reporter
		local requestBody
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					local success, result = pcall(HttpService.JSONDecode, HttpService, requestObj.Body)
					if success then
						requestBody = result
					end
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
		end)

		it("should send error report", function()
			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)
			expect(requestsSent).to.equal(1)

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)
			expect(requestsSent).to.equal(2)
		end)

		it("should set details in the report if it's not nil", function()
			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack, "SomeDetails")
			expect(requestsSent).to.equal(1)
			expect(requestBody.annotations.stackDetails).to.equal("SomeDetails")
		end)
	end)

	describe("reportErrorDeferred()", function()
		local requestsSent
		local reporter
		local requestBody
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					local success, result = pcall(HttpService.JSONDecode, HttpService, requestObj.Body)
					if success then
						requestBody = result
					end
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
				queueOptions = {
					-- The queue should flush when there are 2 or more than 2 errors.
					queueErrorLimit = 2,
				},
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
		end)

		it("should add error to a queue and send later", function()
			reporter:reportErrorDeferred(mockErrorMessage, mockErrorStack)
			expect(requestsSent).to.equal(0)

			reporter:reportErrorDeferred(mockErrorMessage, mockErrorStack)

			-- These 2 errors would be squashed together
			expect(requestsSent).to.equal(1)
			expect(requestBody.attributes.ErrorCount).to.equal(2)
		end)

		it("should set details in the report if it's not nil", function()
			reporter:reportErrorDeferred(mockErrorMessage, mockErrorStack, "SomeDetails")
			reporter:reportErrorDeferred(mockErrorMessage, mockErrorStack, "SomeDetails")

			expect(requestsSent).to.equal(1)
			expect(requestBody.annotations.stackDetails).to.equal("SomeDetails")
		end)
	end)

	describe("arguments.processErrorReportMethod()", function()
		local requestsSent
		local reporter
		local requestBody
		local processReportFunc
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					local success, result = pcall(HttpService.JSONDecode, HttpService, requestObj.Body)
					if success then
						requestBody = result
					end
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
				queueOptions = {
					-- The queue should flush when there are 2 or more than 2 errors.
					queueErrorLimit = 2,
				},
				processErrorReportMethod = function(report)
					if not processReportFunc then
						processReportFunc = function(report)
							return report
						end
					end
					return processReportFunc(report)
				end,
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
			processReportFunc = nil
		end)


		it("should modify the error reports if passed in - reportErrorImmediately", function()
			processReportFunc = function(report)
				report.uuid = "id"
				report.timestamp = 1
				report:addAttributes({
					["Message"] = "test",
				})
				return report
			end

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
			expect(requestBody.uuid).to.equal("id")
			expect(requestBody.timestamp).to.equal(1)
			expect(requestBody.attributes["Message"]).to.equal("test")
		end)

		it("should modify the error reports if passed in - reportErrorDeferred", function()
			processReportFunc = function(report)
				report.uuid = "id"
				report.timestamp = 1
				report:addAttributes({
					["Message"] = "test",
				})
				return report
			end

			reporter:reportErrorDeferred(mockErrorMessage, mockErrorStack)
			reporter:reportAllErrors()
			
			expect(requestsSent).to.equal(1)
			expect(requestBody.uuid).to.equal("id")
			expect(requestBody.timestamp).to.equal(1)
			expect(requestBody.attributes["Message"]).to.equal("test")
		end)
	end)

	describe("updateSharedAttributes()", function()
		local requestsSent
		local reporter
		local requestBody
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					local success, result = pcall(HttpService.JSONDecode, HttpService, requestObj.Body)
					if success then
						requestBody = result
					end
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
		end)

		it("should put the same attributes to all error reports", function()
			reporter:updateSharedAttributes({
				["Message"] = "test",
				["Locale"] = "en-us",
			})

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
			expect(requestBody.threads)
			expect(requestBody.attributes["Message"]).to.equal("test")
			expect(requestBody.attributes["Locale"]).to.equal("en-us")

			requestBody = nil
			reporter:reportErrorImmediately("some other message", mockErrorStack)

			expect(requestsSent).to.equal(2)
			expect(requestBody.attributes["Message"]).to.equal("test")
			expect(requestBody.attributes["Locale"]).to.equal("en-us")
		end)

		it("should merge attributes if called more than once", function()
			reporter:updateSharedAttributes({
				["Message"] = "test",
				["Locale"] = "en-us",
			})

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
			expect(requestBody.attributes["Message"]).to.equal("test")
			expect(requestBody.attributes["Locale"]).to.equal("en-us")

			reporter:updateSharedAttributes({
				["Message"] = Cryo.None,
				["Locale"] = "zh-cn",
				["Theme"] = "light",
			})

			requestBody = nil
			reporter:reportErrorImmediately("some other message", mockErrorStack)

			expect(requestsSent).to.equal(2)
			expect(requestBody.attributes["Message"]).to.equal(nil)
			expect(requestBody.attributes["Locale"]).to.equal("zh-cn")
			expect(requestBody.attributes["Theme"]).to.equal("light")
		end)

		it("should throw if new attributes are ill-formatted", function()
			expect(function()
				reporter:updateSharedAttributes({
					["Message"] = Cryo.None,
					["Locale"] = "zh-cn",
					["Theme"] = function() end, -- callbacks are not allowed
				})
			end).to.throw()
		end)
	end)

	describe("updateSharedAnnotations()", function()
		local requestsSent
		local reporter
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
		end)

		it("should add the same annotations to all error reports", function()
			local requestsSent = 0
			local requestBody = nil
			local reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					requestBody = HttpService:JSONDecode(requestObj.Body)
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})

			local annotations = {
				["Message"] = "test",
				["AppInfo"] = {
					["Locale"] = "en-us",
					["Theme"] = "light",
				},
			}
			reporter:updateSharedAnnotations(annotations)

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
			expect(deepEqual(annotations, requestBody.annotations)).to.equal(true)

			requestBody = nil
			reporter:reportErrorImmediately("some other message", mockErrorStack)

			expect(requestsSent).to.equal(2)
			expect(deepEqual(annotations, requestBody.annotations)).to.equal(true)

			reporter:stop()
		end)

		it("should merge annotations if called more than once", function()
			local requestsSent = 0
			local requestBody = nil
			local reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					requestBody = HttpService:JSONDecode(requestObj.Body)
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})

			local annotations = {
				["Message"] = "test",
				["AppInfo"] = {
					["Locale"] = "en-us",
					["Theme"] = "light",
				},
				["AppVersion"] = "1.0",
			}
			reporter:updateSharedAnnotations(annotations)

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
			expect(deepEqual(annotations, requestBody.annotations)).to.equal(true)

			reporter:updateSharedAnnotations({
				["Message"] = Cryo.None,
				["AppInfo"] = {
					["Theme"] = "dark",
				},
			})

			requestBody = nil
			reporter:reportErrorImmediately("some other message", mockErrorStack)

			local expectedAnnotations = {
				["AppInfo"] = {
					["Theme"] = "dark",
				},
				["AppVersion"] = "1.0",
			}
			expect(requestsSent).to.equal(2)
			expect(deepEqual(expectedAnnotations, requestBody.annotations)).to.equal(true)

			reporter:stop()
		end)

		it("should throw if new annotations are ill-formatted", function()
			local requestsSent = 0
			local reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
			})

			expect(function()
				reporter:updateSharedAnnotations({
					["Message"] = Cryo.None,
					["AppInfo"] = {
						["Locale"] = "en-us",
						["Theme"] = function() end, -- callbacks are not allowed
					},
				})
			end).to.throw()

			reporter:stop()
		end)
	end)

	describe("Logging", function()
		local requestsSent
		local reporter
		local requestBody
		local generateLogFunc
		local logInterval
		beforeEach(function()
			requestsSent = 0
			reporter = BacktraceReporter.new({
				networking = createMockNetworking(function(requestObj)
					requestBody = requestObj.Body
					requestsSent = requestsSent + 1
					return requestBodySuccess
				end),
				accessToken = "12345",
				generateLogMethod = function()
					return generateLogFunc()
				end,
				logIntervalInSeconds = logInterval,
			})
		end)

		afterEach(function()
			reporter:stop()
			reporter = nil
			requestsSent = 0
			requestBody = nil
			logInterval = nil
		end)

		it("should send logs if provided generateLogMethod and error report is successful", function()
			local logText = "test log text"

			generateLogFunc = function()
				return logText
			end

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(2) -- one for error, one for log
			expect(requestBody).to.equal(logText)
		end)

		it("should not send log if generateLogMethod did not return a string", function()
			generateLogFunc = function()
				return 123
			end

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(1)
		end)

		it("should not send more than 1 log in logIntervalInSeconds provided", function()
			logInterval = 2
			local logText = "test log text"
			generateLogFunc = function()
				return logText
			end
			
			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)

			expect(requestsSent).to.equal(2) -- one for error, one for log
			expect(requestBody).to.equal(logText)

			reporter:reportErrorImmediately(mockErrorMessage, mockErrorStack)
			expect(requestsSent).to.equal(3) -- only one more, the error report

			reporter:stop()
		end)
	end)
end
