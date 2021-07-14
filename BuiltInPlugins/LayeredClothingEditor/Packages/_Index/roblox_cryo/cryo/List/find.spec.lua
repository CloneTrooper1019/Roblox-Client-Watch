return function()
	local find = require(script.Parent.find)

	it("should return the correct index", function()
		local a = {5, 4, 3, 2, 1}

		expect(find(a, 1)).to.equal(5)
		expect(find(a, 2)).to.equal(4)
		expect(find(a, 3)).to.equal(3)
		expect(find(a, 4)).to.equal(2)
		expect(find(a, 5)).to.equal(1)
	end)

	it("should work with an empty table", function()
		expect(find({}, 1)).to.equal(nil)
	end)

	it("should return nil when the given value is not found", function()
		local a = {1, 2, 3}

		expect(find(a, 4)).to.equal(nil)
		expect(type(find(a, 4))).to.equal("nil")
	end)

	it("should return the index of the first value found", function()
		local list = {1, 2, 2}

		expect(find(list, 2)).to.equal(2)
	end)
end