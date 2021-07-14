return function()
	local Networking = require(script.Parent.Networking)
	local HttpService = game:GetService("HttpService")

	local FFlagStudioFixFrameworkJsonParsing = game:GetFastFlag("StudioFixFrameworkJsonParsing")

	describe("new()", function()
		it("should construct with no params", function()
			local n = Networking.new()
			expect(n).to.be.ok()
		end)
	end)


	describe("mock()", function()
		it("should construct with no params", function()
			local n = Networking.mock()
			expect(n).to.be.ok()
		end)

		it("should give you the default response if you don't define a proper response", function()
			local n = Networking.mock()

			local didError = false
			n:get("https://www.test.com/fakeApi?a=1&b=2"):andThen(function(httpResponse)
				expect(httpResponse.responseBody).to.equal("{}")
				expect(httpResponse.responseCode).to.equal(200)
			end, function(err)
				didError = true
				warn(err.responseBody)
			end)

			expect(didError).to.equal(false)
		end)

		it("should allow you mock the server response", function()
			local callCount = 0
			local responseCallCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					expect(requestOptions.Url).to.equal("https://www.test.com/fakeApi")

					return {
						Body = "hello world",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			n:get("https://www.test.com/fakeApi"):andThen(function(testResponse)
				responseCallCount = responseCallCount + 1

				expect(testResponse.responseTimeMs > 0).to.equal(true)
				expect(testResponse.responseCode).to.equal(200)
				expect(testResponse.responseBody).to.equal("hello world")
				expect(testResponse.requestOptions.Url).to.equal("https://www.test.com/fakeApi")
				expect(testResponse.requestOptions.Method).to.equal("GET")
			end):await()

			expect(callCount).to.equal(1)
			expect(responseCallCount).to.equal(1)
		end)
	end)


	describe("_isLoggingEnabled()", function()
		it("should log nothing when set to NONE", function()
			local n = Networking.mock({ loggingLevel = 0 }) -- LOGGING_CHANNELS.NONE
			expect(n:_isLoggingEnabled(1)).to.equal(false)
			expect(n:_isLoggingEnabled(2)).to.equal(false)
			expect(n:_isLoggingEnabled(3)).to.equal(false)
			expect(n:_isLoggingEnabled(4)).to.equal(false)
			expect(n:_isLoggingEnabled(5)).to.equal(false)
			expect(n:_isLoggingEnabled(6)).to.equal(false)
			expect(n:_isLoggingEnabled(7)).to.equal(false)
		end)

		it("should log information for REQUEST channels", function()
			local n = Networking.mock({ loggingLevel = 1 }) -- LOGGING_CHANNELS.REQUESTS
			expect(n:_isLoggingEnabled(1)).to.equal(true)
			expect(n:_isLoggingEnabled(2)).to.equal(false)
			expect(n:_isLoggingEnabled(3)).to.equal(true)
			expect(n:_isLoggingEnabled(4)).to.equal(false)
			expect(n:_isLoggingEnabled(5)).to.equal(true)
			expect(n:_isLoggingEnabled(6)).to.equal(false)
			expect(n:_isLoggingEnabled(7)).to.equal(true)
		end)

		it("should log information for RESPONSES channels", function()
			local n = Networking.mock({ loggingLevel = 2 }) -- LOGGING_CHANNELS.RESPONSES
			expect(n:_isLoggingEnabled(1)).to.equal(false)
			expect(n:_isLoggingEnabled(2)).to.equal(true)
			expect(n:_isLoggingEnabled(3)).to.equal(true)
			expect(n:_isLoggingEnabled(4)).to.equal(false)
			expect(n:_isLoggingEnabled(5)).to.equal(false)
			expect(n:_isLoggingEnabled(6)).to.equal(true)
			expect(n:_isLoggingEnabled(7)).to.equal(true)
		end)

		it("should log information for DEBUG channels", function()
			local n = Networking.mock({ loggingLevel = 4 }) -- LOGGING_CHANNELS.DEBUG
			expect(n:_isLoggingEnabled(1)).to.equal(false)
			expect(n:_isLoggingEnabled(2)).to.equal(false)
			expect(n:_isLoggingEnabled(3)).to.equal(false)
			expect(n:_isLoggingEnabled(4)).to.equal(true)
			expect(n:_isLoggingEnabled(5)).to.equal(true)
			expect(n:_isLoggingEnabled(6)).to.equal(true)
			expect(n:_isLoggingEnabled(7)).to.equal(true)
		end)

		it("should log everything when set to VERBOSE", function()
			local n = Networking.mock({ loggingLevel = 7 }) -- LOGGING_CHANNELS.VERBOSE
			expect(n:_isLoggingEnabled(1)).to.equal(true)
			expect(n:_isLoggingEnabled(2)).to.equal(true)
			expect(n:_isLoggingEnabled(3)).to.equal(true)
			expect(n:_isLoggingEnabled(4)).to.equal(true)
			expect(n:_isLoggingEnabled(5)).to.equal(true)
			expect(n:_isLoggingEnabled(6)).to.equal(true)
			expect(n:_isLoggingEnabled(7)).to.equal(true)
		end)
	end)


	describe("parseJson()", function()
		it("should take a successful HttpResponse and parse the body", function()
			local n = Networking.mock({
				onRequest = function(requestOptions)
					return {
						Body = HttpService:JSONEncode({
							message = {
								a = {
									b = "foo",
								},
							},
						}),
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			local didError = false
			local httpPromise = n:get("https://www.test.com")
			n:parseJson(httpPromise):andThen(function(json)
				local body = json.responseBody
				expect(body.message.a.b).to.equal("foo")
			end, function()
				didError = true
			end)

			expect(didError).to.equal(false)
		end)

		if FFlagStudioFixFrameworkJsonParsing then
			it("should return a rejected Promise if the body fails to parse", function()
				local n = Networking.mock({
					onRequest = function(requestOptions)
						return {
							Body = "I'm not valid JSON",
							Success = true,
							StatusMessage = "OK",
							StatusCode = 200,
						}
					end,
				})

				local didResolve = false
				local didError = false
				local httpPromise = n:get("https://www.test.com")
				n:parseJson(httpPromise):andThen(function(json)
					didResolve = true
				end, function(err)
					expect((string.find(err, "Can't parse JSON"))).to.never.equal(nil)
					didError = true
				end)

				expect(didResolve).to.equal(false)
				expect(didError).to.equal(true)
			end)

			it("should return a rejected Promise if the request failed", function()
				local n = Networking.mock({
					onRequest = function(requestOptions)
						return {
							Body = "I'm not valid JSON",
							Success = false,
							StatusMessage = "Forbidden",
							StatusCode = 401,
						}
					end,
				})

				local didError = false
				local didResolve = false
				local foundExpectedErrMsg = false

				local httpPromise = n:get("https://www.test.com")
				n:parseJson(httpPromise):andThen(function(json)
					didResolve = true
				end, function(err)
					foundExpectedErrMsg = string.find(tostring(err), "Can't parse JSON") == nil
					didError = true
				end)

				expect(didResolve).to.equal(false)
				expect(didError).to.equal(true)
				expect(foundExpectedErrMsg).to.equal(true)
			end)

			it("should return a rejected Promise with a parsed body if the body is parsable", function()
				local n = Networking.mock({
					onRequest = function(requestOptions)
						return {
							Body = HttpService:JSONEncode({ errors = {
								message = "You gotta log in my dude."
							} }),
							Success = false,
							StatusMessage = "Forbidden",
							StatusCode = 401,
						}
					end,
				})

				local didError = false
				local didResolve = false
				local foundExpectedBody = false

				local httpPromise = n:get("https://www.test.com")
				n:parseJson(httpPromise):andThen(function(json)
					didResolve = true
				end, function(err)
					foundExpectedBody = err.responseBody.errors.message == "You gotta log in my dude."
					didError = true
				end)

				expect(didResolve).to.equal(false)
				expect(didError).to.equal(true)
				expect(foundExpectedBody).to.equal(true)
			end)
		end
	end)


	describe("handleRetry()", function()
		it("should retry only if the request fails", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1

					return {
						Body = "foo",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			local didError = false
			local httpPromise = n:get("https://www.test.com")
			n:handleRetry(httpPromise, 3, true):andThen(function(response)
				expect(response.responseBody).to.equal("foo")
			end, function()
				didError = true
			end)

			expect(didError).to.equal(false)
			expect(callCount).to.equal(1)
		end)

		it("should retry up to 3 times if a request fails", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					return {
						Body = "{ \"message\":\"foo\" }",
						Success = false,
						StatusMessage = "Server Error",
						StatusCode = 500,
					}
				end,
			})

			local didError = false
			local httpPromise = n:get("https://www.test.com")
			n:handleRetry(httpPromise, 3, true):catch(function()
				didError = true
			end)

			expect(didError).to.equal(true)
			expect(callCount).to.equal(4) -- 1 original + 3 retries
		end)

		it("should retry only as many times as it needs to succeed", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1

					-- after a few retries, return a success
					if callCount == 2 then
						return {
							Body = "foo",
							Success = true,
							StatusMessage = "OK",
							StatusCode = 200,
						}
					end

					return {
						Body = "bad",
						Success = false,
						StatusMessage = "Server Error",
						StatusCode = 500,
					}
				end,
			})

			local didError = false
			local httpPromise = n:get("https://www.test.com")
			n:handleRetry(httpPromise, 3, true):andThen(function(response)
				expect(response.responseBody).to.equal("foo")
			end, function()
				didError = true
			end)

			expect(didError).to.equal(false)
			expect(callCount).to.equal(2) -- 1 original + 1 retries
		end)

		it("should not retry on 4xx errors", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					return {
						Body = "{ \"message\":\"foo\" }",
						Success = false,
						StatusMessage = "Bad Request",
						StatusCode = 400,
					}
				end,
			})

			local didError = false
			local httpPromise = n:get("https://www.example.com")
			n:handleRetry(httpPromise, 3, true):catch(function()
				didError = true
			end)

			expect(didError).to.equal(true)
			expect(callCount).to.equal(1)
		end)

		it("should not retry POST requests", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1

					return {
						Body = "bad",
						Success = false,
						StatusMessage = "Server Error",
						StatusCode = 500,
					}
				end,
			})

			local didError = false
			local httpPromise = n:post("https://www.test.com")
			n:handleRetry(httpPromise, 3, true):andThen(function(response)
				expect(response.responseBody).to.equal("foo")
			end, function()
				didError = true
			end)

			expect(didError).to.equal(true)
			expect(callCount).to.equal(1)
		end)

		it("should not retry PATCH requests", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1

					return {
						Body = "bad",
						Success = false,
						StatusMessage = "Server Error",
						StatusCode = 500,
					}
				end,
			})

			local didError = false
			local httpPromise = n:patch("https://www.test.com")
			n:handleRetry(httpPromise, 3, true):andThen(function(response)
				expect(response.responseBody).to.equal("foo")
			end, function()
				didError = true
			end)

			expect(didError).to.equal(true)
			expect(callCount).to.equal(1)
		end)
	end)


	describe("request()", function()
		it("should validate its inputs", function()
			local n = Networking.mock()
			expect(function()
				-- missing method
				n:request({
					Url = "http://www.test.com"
				})
			end).to.throw()

			expect(function()
				-- missing url
				n:request({
					Method = "GET"
				})
			end).to.throw()
		end)

		it("should return a Promise that resolves to an HttpResponse object", function()
			local n = Networking.mock({
				onRequest = function(requestOptions)
					return {
						Body = "{ message=\"success\" }",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			local httpPromise = n:request({
				Method = "GET",
				Url = "https://www.test.com"
			})
			expect(httpPromise).to.be.ok()

			local didError = false
			httpPromise:andThen(function(response)
				expect(response.responseBody).to.equal("{ message=\"success\" }")
				expect(response.responseCode).to.equal(200)
				expect(response.requestOptions.Method).to.equal("GET")
				expect(response.requestOptions.Url).to.equal("https://www.test.com")
				expect(response.responseTimeMs > 0).to.equal(true)
			end, function()
				didError = true
			end)

			expect(didError).to.equal(false)
		end)

		it("should return a Promise that rejects if the request fails", function()
			local n = Networking.mock({
				onRequest = function(requestOptions)
					return {
						Body = "{ message=\"failure\" }",
						Success = false,
						StatusMessage = "Forbidden",
						StatusCode = 403,
					}
				end,
			})

			local httpPromise = n:request({ Method = "GET", Url = "https://www.test.com" })
			expect(httpPromise).to.be.ok()

			local didError = false
			local didResolve = false
			httpPromise:andThen(function()
				didResolve = true
			end, function(errResponse)
				didError = true
				expect(errResponse.responseBody).to.equal("{ message=\"failure\" }")
				expect(errResponse.responseCode).to.equal(403)
				expect(errResponse.requestOptions.Method).to.equal("GET")
				expect(errResponse.requestOptions.Url).to.equal("https://www.test.com")
				expect(errResponse.responseTimeMs > 0).to.equal(true)
			end)

			expect(didResolve).to.equal(false)
			expect(didError).to.equal(true)
		end)

		it("should call RequestAsync by default", function()
			local asyncCallCount = 0
			local internalCallCount = 0

			local fakeResponse = {
				Body = "{}",
				Success = true,
				StatusMessage = "OK",
				StatusCode = 200,
			}

			local fakeHttpService = {
				ClassName = "RequstTestAsync"
			}
			function fakeHttpService.RequestAsync()
				asyncCallCount = asyncCallCount + 1
				return fakeResponse
			end
			function fakeHttpService.RequestInternal()
				internalCallCount = internalCallCount + 1
				return {
					Start = function()
						return fakeResponse
					end
				}
			end

			local n = Networking.new({
				httpImpl = fakeHttpService,
				allowYielding = false,
			})

			n:request({ Url = "www.test.com", Method = "GET" })

			expect(asyncCallCount).to.equal(1)
			expect(internalCallCount).to.equal(0)
		end)

		it("should call RequestInternal if marked as 'isInternal'", function()
			local asyncCallCount = 0
			local internalCallCount = 0

			local fakeResponse = {
				Body = "{}",
				Success = true,
				StatusMessage = "OK",
				StatusCode = 200,
			}

			local fakeHttpService = {
				ClassName = "RequstTestInternal"
			}
			function fakeHttpService.RequestAsync()
				asyncCallCount = asyncCallCount + 1
				return fakeResponse
				
			end
			function fakeHttpService.RequestInternal()
				internalCallCount = internalCallCount + 1
				return {
					Start = function()
						return fakeResponse
					end
				}
			end

			local n = Networking.new({
				httpImpl = fakeHttpService,
				isInternal = true,
				allowYielding = false,
			})

			n:request({ Url = "www.test.com", Method = "GET" })

			expect(asyncCallCount).to.equal(0)
			expect(internalCallCount).to.equal(1)
		end)
	end)


	describe("get()", function()
		it("should act as a preformatted version of Request", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					expect(requestOptions.Url).to.equal("http://www.test.com")
					expect(requestOptions.Method).to.equal("GET")
					return {
						Body = "foo",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			n:get("http://www.test.com")

			expect(callCount).to.equal(1)
		end)
	end)


	describe("post()", function()
		it("should act as a preformatted version of Request", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					expect(requestOptions.Url).to.equal("http://www.test.com")
					expect(requestOptions.Method).to.equal("POST")
					expect(requestOptions.Body).to.equal("bar")
					return {
						Body = "foo",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			n:post("http://www.test.com", "bar")

			expect(callCount).to.equal(1)
		end)
	end)

	describe("patch()", function()
		it("should act as a preformatted version of Request", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					expect(requestOptions.Url).to.equal("http://www.test.com")
					expect(requestOptions.Method).to.equal("PATCH")
					expect(requestOptions.Body).to.equal("bar")
					return {
						Body = "foo",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			n:patch("http://www.test.com", "bar")

			expect(callCount).to.equal(1)
		end)
	end)

	describe("delete()", function()
		it("should act as a preformatted version of Request", function()
			local callCount = 0

			local n = Networking.mock({
				onRequest = function(requestOptions)
					callCount = callCount + 1
					expect(requestOptions.Url).to.equal("http://www.test.com")
					expect(requestOptions.Method).to.equal("DELETE")
					return {
						Body = "foo",
						Success = true,
						StatusMessage = "OK",
						StatusCode = 200,
					}
				end,
			})

			n:delete("http://www.test.com")

			expect(callCount).to.equal(1)
		end)
	end)
end
