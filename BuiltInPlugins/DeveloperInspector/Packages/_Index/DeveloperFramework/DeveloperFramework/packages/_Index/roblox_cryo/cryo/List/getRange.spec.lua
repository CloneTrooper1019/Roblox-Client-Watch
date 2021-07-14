return function()
	local getRange = require(script.Parent.getRange)

	it("should return the correct range", function()
		local a = {1, 2, 3, 4}
		local b = getRange(a, 2, 3)

		expect(b[1]).to.equal(2)
		expect(b[2]).to.equal(3)
		expect(#b).to.equal(2)

		local c = getRange(a, 4, 4)
		expect(#c).to.equal(1)
		expect(c[1]).to.equal(4)
	end)

	it("should throw when the start index is higher than the end index", function()
		local a = {5, 8, 7, 2, 3, 7}

		expect(function()
			getRange(a, 4, 1)
		end).to.throw()
	end)

	it("should copy the table", function()
		local a = {6, 8, 1, 3, 7, 2}
		local b = getRange(a, 1, #a)

		for key, value in pairs(a) do
			expect(b[key]).to.equal(value)
		end

		for key, value in pairs(b) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should work with an empty table", function()
		local a = getRange({}, 1, 5)

		expect(a).to.be.a("table")
		expect(#a).to.equal(0)
	end)

	it("should work when the start index is smaller that 1", function()
		local a = {1, 2, 3, 4}
		local b = getRange(a, -2, 2)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(2)
	end)

	it("should work when the end index is larger that the list length", function()
		local a = {1, 2, 3, 4}
		local b = getRange(a, 3, 18)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(3)
		expect(b[2]).to.equal(4)
	end)
end