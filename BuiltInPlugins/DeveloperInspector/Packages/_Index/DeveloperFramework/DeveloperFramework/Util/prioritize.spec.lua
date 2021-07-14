return function()
	local prioritize = require(script.Parent.prioritize)

	it("should return the first argument if not nil", function()
		local value = prioritize(1, 2, 3)
		expect(value).to.equal(1)
	end)

	it("should return the second argument if the first is nil", function()
		local value = prioritize(nil, 2, 3)
		expect(value).to.equal(2)
	end)

	it("should return the third argument if the first two are nil", function()
		local value = prioritize(nil, nil, 3)
		expect(value).to.equal(3)
	end)

	it("should return nil if missing all 3 options", function()
		local value = prioritize(nil, nil, nil)
		expect(value).to.equal(nil)
	end)
end