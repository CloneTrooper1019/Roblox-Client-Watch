return function()
	local Promise = require(script.Parent.Promise)

	describe("Promise.new", function()
		it("should instantiate with a callback", function()
			local promise = Promise.new(function() end)

			expect(promise).to.be.ok()
		end)

		it("should invoke the given callback with resolve and reject", function()
			local callCount = 0
			local resolveArg
			local rejectArg

			local promise = Promise.new(function(resolve, reject)
				callCount = callCount + 1
				resolveArg = resolve
				rejectArg = reject
			end)

			expect(promise).to.be.ok()

			expect(callCount).to.equal(1)
			expect(resolveArg).to.be.a("function")
			expect(rejectArg).to.be.a("function")
			expect(promise._status).to.equal(Promise.Status.Started)
		end)

		it("should resolve promises on resolve()", function()
			local callCount = 0

			local promise = Promise.new(function(resolve)
				callCount = callCount + 1
				resolve()
			end)

			expect(promise).to.be.ok()
			expect(callCount).to.equal(1)
			expect(promise._status).to.equal(Promise.Status.Resolved)
		end)

		it("should reject promises on reject()", function()
			local callCount = 0

			local promise = Promise.new(function(resolve, reject)
				callCount = callCount + 1
				reject()
			end)

			expect(promise).to.be.ok()
			expect(callCount).to.equal(1)
			expect(promise._status).to.equal(Promise.Status.Rejected)

			-- Avoid unhandled rejection
			promise:catch(function() end)
		end)

		it("should reject on error in callback", function()
			local callCount = 0

			local promise = Promise.new(function()
				callCount = callCount + 1
				error("hahah")
			end)

			expect(promise).to.be.ok()
			expect(callCount).to.equal(1)
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]:find("hahah")).to.be.ok()

			-- Avoid unhandled rejection
			promise:catch(function() end)
		end)
	end)

	describe("Promise.resolve", function()
		it("should immediately resolve with a value", function()
			local promise = Promise.resolve(5)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Resolved)
			expect(promise._value[1]).to.equal(5)
		end)

		it("should chain onto passed promises", function()
			local promise = Promise.resolve(Promise.new(function(_, reject)
				reject(7)
			end))

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]).to.equal(7)

			-- Avoid unhandled rejection
			promise:catch(function() end)
		end)
	end)

	describe("Promise.reject", function()
		it("should immediately reject with a value", function()
			local promise = Promise.reject(6)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]).to.equal(6)

			-- Avoid unhandled rejection
			promise:catch(function() end)
		end)

		it("should pass a promise as-is as an error", function()
			local innerPromise = Promise.new(function(resolve)
				resolve(6)
			end)

			local promise = Promise.reject(innerPromise)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]).to.equal(innerPromise)

			-- Avoid unhandled rejection
			promise:catch(function() end)
		end)
	end)

	describe("Promise:andThen", function()
		it("should chain onto resolved promises", function()
			local args
			local argsLength
			local callCount = 0
			local badCallCount = 0

			local promise = Promise.resolve(5)

			local chained = promise
				:andThen(function(...)
					args = {...}
					argsLength = select("#", ...)
					callCount = callCount + 1
				end, function()
					badCallCount = badCallCount + 1
				end)

			expect(badCallCount).to.equal(0)

			expect(callCount).to.equal(1)
			expect(argsLength).to.equal(1)
			expect(args[1]).to.equal(5)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Resolved)
			expect(promise._value[1]).to.equal(5)

			expect(chained).to.be.ok()
			expect(chained).never.to.equal(promise)
			expect(chained._status).to.equal(Promise.Status.Resolved)
			expect(#chained._value).to.equal(0)
		end)

		it("should chain onto rejected promises", function()
			local args
			local argsLength
			local callCount = 0
			local badCallCount = 0

			local promise = Promise.reject(5)

			local chained = promise
				:andThen(function(...)
					badCallCount = badCallCount + 1
				end, function(...)
					args = {...}
					argsLength = select("#", ...)
					callCount = callCount + 1
				end)

			expect(badCallCount).to.equal(0)

			expect(callCount).to.equal(1)
			expect(argsLength).to.equal(1)
			expect(args[1]).to.equal(5)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]).to.equal(5)

			expect(chained).to.be.ok()
			expect(chained).never.to.equal(promise)
			expect(chained._status).to.equal(Promise.Status.Resolved)
			expect(#chained._value).to.equal(0)
		end)

		it("should chain onto asynchronously resolved promises", function()
			local args
			local argsLength
			local callCount = 0
			local badCallCount = 0

			local startResolution
			local promise = Promise.new(function(resolve)
				startResolution = resolve
			end)

			local chained = promise
				:andThen(function(...)
					args = {...}
					argsLength = select("#", ...)
					callCount = callCount + 1
				end, function()
					badCallCount = badCallCount + 1
				end)

			expect(callCount).to.equal(0)
			expect(badCallCount).to.equal(0)

			startResolution(6)

			expect(badCallCount).to.equal(0)

			expect(callCount).to.equal(1)
			expect(argsLength).to.equal(1)
			expect(args[1]).to.equal(6)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Resolved)
			expect(promise._value[1]).to.equal(6)

			expect(chained).to.be.ok()
			expect(chained).never.to.equal(promise)
			expect(chained._status).to.equal(Promise.Status.Resolved)
			expect(#chained._value).to.equal(0)
		end)

		it("should chain onto asynchronously rejected promises", function()
			local args
			local argsLength
			local callCount = 0
			local badCallCount = 0

			local startResolution
			local promise = Promise.new(function(_, reject)
				startResolution = reject
			end)

			local chained = promise
				:andThen(function()
					badCallCount = badCallCount + 1
				end, function(...)
					args = {...}
					argsLength = select("#", ...)
					callCount = callCount + 1
				end)

			expect(callCount).to.equal(0)
			expect(badCallCount).to.equal(0)

			startResolution(6)

			expect(badCallCount).to.equal(0)

			expect(callCount).to.equal(1)
			expect(argsLength).to.equal(1)
			expect(args[1]).to.equal(6)

			expect(promise).to.be.ok()
			expect(promise._status).to.equal(Promise.Status.Rejected)
			expect(promise._value[1]).to.equal(6)

			expect(chained).to.be.ok()
			expect(chained).never.to.equal(promise)
			expect(chained._status).to.equal(Promise.Status.Resolved)
			expect(#chained._value).to.equal(0)
		end)
	end)

	-- If you see test failures in here it is probably because other tests in unrelated suites are creating unhandled
	-- rejections due to their not awaiting promises correctly.
	-- Try disabling this suite with describeSKIP to see these unhandled rejections revealed by the default
	-- onUnhandledRejection callback.
	describe("unhandled rejections", function()

		local calls
		local originalOnUnhandledRejection

		local function setup()
			calls = {}
			local handler = function(message)
				table.insert(calls, message)
			end
			originalOnUnhandledRejection = Promise.onUnhandledRejection
			Promise.onUnhandledRejection = handler
		end

		local function teardown()
			Promise.onUnhandledRejection = originalOnUnhandledRejection
		end

		local waitUntilNextTick = function()
			Promise.new(function(fulfil)
				spawn(fulfil)
			end):await()
		end

		-- TODO DEVTOOLS-4397: When TestEZ is updated, use beforeAll/afterAll to setup and teardown the change to onUnhandledRejection

		describe("should not call onUnhandledRejection", function()
			it("if await is called", function()
				setup()

				expect(function()
					Promise.new(function(fulfil, reject)
						reject("it did not work")
					end):await()

				end).to.throw()

				waitUntilNextTick()

				expect(#calls).to.equal(0)
				teardown()
			end)

			it("if andThen is called with an error handler", function()
				setup()

				local caught = false
				Promise.new(function(fulfil, reject)
					reject("it did not work")
				end):andThen(function()
					-- NOOP success handler
				end, function()
					caught = true
				end)

				waitUntilNextTick()

				expect(caught).to.equal(true)
				expect(#calls).to.equal(0)

				teardown()
			end)

			it("if an error handler is added after rejection but before the next tick", function()
				setup()

				local promise = Promise.new(function(fulfil, reject)
					reject("it did not work")
				end)

				expect(promise._unhandledRejection).to.equal(true)

				promise:catch(function(err)
					expect(err:find("it did not work")).to.be.ok()
				end)

				waitUntilNextTick()

				expect(#calls).to.equal(0)
				teardown()
			end)

			it("should not throw if an unhandled rejection occurs with no rejection handler defined", function()
				Promise.new(function(fulfil, reject)
					reject("it did not work")
				end)

				waitUntilNextTick()

				teardown()
			end)
		end)

		describe("should call onUnhandledRejection", function()
			it("if promise rejects", function()
				setup()

				Promise.new(function(fulfil, reject)
					reject("it did not work")
				end)

				waitUntilNextTick()

				expect(#calls).to.equal(1)
				expect(calls[1]:find("it did not work")).to.be.ok()

				teardown()
			end)

			it("if fulfil handler rejects", function()
				setup()

				Promise.new(function(fulfil)
					fulfil("it worked")
				end):andThen(function(result)
					error("Error from fulfil")
				end)

				waitUntilNextTick()

				expect(#calls).to.equal(1)
				expect(calls[1]:find("Error from fulfil")).to.be.ok()

				teardown()
			end)

			it("if andThen is called but no error handler is registered", function()
				setup()

				Promise.new(function(fulfil, reject)
					reject("it did not work")
				end):andThen(function()
					-- NOOP success handler
				end)

				waitUntilNextTick()

				expect(#calls).to.equal(1)
				expect(calls[1]:find("it did not work")).to.be.ok()

				teardown()
			end)


			it("should not throw if onUnhandledRejection throws", function()
				setup()
				Promise.onUnhandledRejection = function()
					error("My error")
				end

				Promise.new(function(fulfil, reject)
					reject("it did not work")
				end):andThen(function()
					-- NOOP success handler
				end)

				waitUntilNextTick()

				teardown()
			end)
		end)
	end)
end
