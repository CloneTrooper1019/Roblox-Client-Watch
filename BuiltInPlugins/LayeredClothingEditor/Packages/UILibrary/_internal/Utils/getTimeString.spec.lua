return function()
	local getTimeString = require(script.Parent.getTimeString)

	it("should return a string", function()
		local result = getTimeString(0)

		expect(result).to.be.a("string")
	end)

	it("should handle 30 seconds correctly", function()
		local result = getTimeString(30)

		expect(result).to.equal("0:30")
	end)

	it("should ignore decimals", function()
		local result = getTimeString(1.5)

		expect(result).to.equal("0:01")
	end)

	it("should ignore negative decimals", function()
		local result = getTimeString(-1.5)

		expect(result).to.equal("-0:01")
	end)

	it("should handle 60 seconds correctly", function()
		local result = getTimeString(60)

		expect(result).to.equal("1:00")
	end)

	it("should handle 90 seconds correctly", function()
		local result = getTimeString(90)

		expect(result).to.equal("1:30")
	end)

	it("should handle 120 seconds correctly", function()
		local result = getTimeString(120)

		expect(result).to.equal("2:00")
	end)

	it("should handle 150 seconds correctly", function()
		local result = getTimeString(150)

		expect(result).to.equal("2:30")
	end)
end