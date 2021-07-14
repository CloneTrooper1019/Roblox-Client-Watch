return function()
	local ErrorQueue = require(script.Parent.ErrorQueue)

	local Framework = script.Parent.Parent
	local deepEqual = require(Framework.Util.deepEqual)

	local errorsToAdd = {
		[1] = {
			key = "test",
			value = 2.33,
		},
		[2] = {
			key = "test",
			value = 2,
		},
		[3] = {
			key = "test",
			value = 3.14,
		},
		[4] = {
			key = "test2",
			value = 123,
		},
		[5] = {
			key = "test2",
			value = 456,
		},
		[6] = {
			key = "test3",
			value = "something",
		},
	}

	describe("queueErrorLimit", function()
		it("should report errors correctly when the total error limit is reached", function()
			local expectedErrorsReported = {
				["test"] = {
					data = 2.33,
					count = 3,
				},
				["test2"] = {
					data = 123,
					count = 2,
				},
				["test3"] = {
					data = "something",
					count = 1,
				},
			}

			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueErrorLimit = 6,
			})

			for _, err in ipairs(errorsToAdd) do
				errorQueue:addError(err.key, err.value)
			end

			expect(reportCount).to.equal(3)
			for errorKey, expectedError in pairs(expectedErrorsReported) do
				expect(deepEqual(expectedError, errorsReported[errorKey])).to.equal(true)
			end
		end)

		it("should not report errors before the total error limit is reached", function()
			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueErrorLimit = 6,
			})

			for index = 1, 5 do
				local error = errorsToAdd[index]
				errorQueue:addError(error.key, error.value)
			end

			expect(reportCount).to.equal(0)
			expect(deepEqual(errorsReported, {})).to.equal(true)
		end)
	end)

	describe("queueKeyLimit", function()
		it("should report errors correctly when the total key limit is reached", function()
			local expectedErrorsReported = {
				["test"] = {
					data = 2.33,
					count = 3,
				},
				["test2"] = {
					data = 123,
					count = 2,
				},
				["test3"] = {
					data = "something",
					count = 1,
				},
			}

			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueKeyLimit = 3,
				queueErrorLimit = 100,
			})

			for _, error in ipairs(errorsToAdd) do
				errorQueue:addError(error.key, error.value)
			end

			expect(reportCount).to.equal(3)
			for errorKey, expectedError in pairs(expectedErrorsReported) do
				expect(deepEqual(expectedError, errorsReported[errorKey])).to.equal(true)
			end
		end)

		it("should not report errors before the total key limit is reached", function()
			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueKeyLimit = 4,
				queueErrorLimit = 100,
			})

			for _, error in ipairs(errorsToAdd) do
				errorQueue:addError(error.key, error.value)
			end

			expect(reportCount).to.equal(0)
			expect(deepEqual(errorsReported, {})).to.equal(true)
		end)
	end)

	describe("queueTimeLimit", function()
		it("should report errors correctly when the total time limit is reached", function()
			local expectedErrorsReported = {
				["test"] = {
					data = 2.33,
					count = 3,
				},
				["test2"] = {
					data = 123,
					count = 2,
				},
				["test3"] = {
					data = "something",
					count = 1,
				},
			}

			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueTimeLimit = 0.5,
				queueErrorLimit = 100,
				queueKeyLimit = 100,
			})

			for _, error in ipairs(errorsToAdd) do
				errorQueue:addError(error.key, error.value)
			end

			errorQueue:_onQueueTimerTick(0.5)

			expect(reportCount).to.equal(3)
			for errorKey, expectedError in pairs(expectedErrorsReported) do
				expect(deepEqual(expectedError, errorsReported[errorKey])).to.equal(true)
			end
		end)

		it("should not report errors before the total time limit is reached", function()
			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueTimeLimit = 2,
				queueErrorLimit = 100,
				queueKeyLimit = 100,
			})

			for _, error in ipairs(errorsToAdd) do
				errorQueue:addError(error.key, error.value)
			end

			errorQueue:_onQueueTimerTick(1)

			expect(reportCount).to.equal(0)
			expect(deepEqual(errorsReported, {})).to.equal(true)
		end)
	end)

	describe("reportAllErrors", function()
		it("should report all errors correctly when called", function()
			local expectedErrorsReported = {
				["test"] = {
					data = 2.33,
					count = 3,
				},
				["test2"] = {
					data = 123,
					count = 2,
				},
				["test3"] = {
					data = "something",
					count = 1,
				},
			}

			local errorsReported = {}
			local reportCount = 0
			local reportMethod = function(errorKey, errorData, errorCount)
				reportCount = reportCount + 1
				errorsReported[errorKey] = {
					data = errorData,
					count = errorCount,
				}
			end

			local errorQueue = ErrorQueue.new(reportMethod, {
				queueTimeLimit = 100,
				queueErrorLimit = 100,
				queueKeyLimit = 100,
			})

			for _, error in ipairs(errorsToAdd) do
				errorQueue:addError(error.key, error.value)
			end

			expect(reportCount).to.equal(0)

			errorQueue:reportAllErrors()

			expect(reportCount).to.equal(3)
			for errorKey, expectedError in pairs(expectedErrorsReported) do
				expect(deepEqual(expectedError, errorsReported[errorKey])).to.equal(true)
			end
		end)
	end)
end
