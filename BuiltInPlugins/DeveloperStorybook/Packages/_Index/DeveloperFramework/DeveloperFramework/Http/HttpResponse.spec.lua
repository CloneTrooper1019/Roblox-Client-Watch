return function()
	local HttpResponse = require(script.Parent.HttpResponse)
	local StatusCode = require(script.Parent.StatusCodes)

	describe("new()", function()
		it("should construct without a problem", function()
			expect(function()
				local _ = HttpResponse.new("", 0, StatusCode.OK, {
					Url = "https://www.roblox.com/",
					Method = "GET"
				})
			end).never.to.throw()
		end)

		it("should just pass data through", function()
			local testBody = ""
			local testTime = 203
			local testCode = StatusCode.OK
			local testOptions = {
				Url = "https://www.roblox.com/",
				Method = "GET"
			}

			local response = HttpResponse.new(testBody, testTime, testCode, testOptions)

			expect(response.responseBody).to.equal(testBody)
			expect(response.responseTimeMs).to.equal(testTime)
			expect(response.responseCode).to.equal(testCode)
			expect(response.requestOptions).to.equal(testOptions)
		end)
	end)

	describe("tostring()", function()
		it("should parse to a string without a problem", function()
			local testBody = "foo"
			local testTime = 203
			local testCode = StatusCode.OK
			local testOptions = {
				Url = "https://www.roblox.com/",
				Method = "GET"
			}

			local response = HttpResponse.new(testBody, testTime, testCode, testOptions)
			expect(tostring(response)).to.be.ok()
		end)

		it("should parse to a string when responseBody is a table", function()
			local testBody = { a = 123, b = "foo", c = { 1, 2, 3 }, d = { foo = "bar" }}
			local testTime = 203
			local testCode = StatusCode.OK
			local testOptions = {
				Url = "https://www.roblox.com/",
				Method = "GET"
			}

			local response = HttpResponse.new(testBody, testTime, testCode, testOptions)
			expect(tostring(response)).to.be.ok()
		end)
	end)
end