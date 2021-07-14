return function()
	local pollUntil = require(script.Parent.pollUntil)

	it("works for a function that returns immediately", function()
		pollUntil(function()
			return true
		end):andThen(function()
			-- OK.
		end):await()
	end)

	it("works for a function that returns true later on", function()
		local count = 0
		local resultValue = {}
		local result = pollUntil(function()
			count += 1 
			return count > 3 and resultValue or nil
		end)
		result:andThen(function(value)
			-- OK.
			expect(value).to.equal(resultValue)
		end):await()
	end)

	it("times out correctly", function()
		-- A suitably small time for call to timeout
		local timeout = 0.0001
		local result = pollUntil(function()
			return false
		end, timeout)
		result:andThen(function(value)
			error("Should throw")
		end):catch(function()
			-- OK.
		end):await()
	end)
end