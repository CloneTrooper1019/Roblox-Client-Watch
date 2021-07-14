return function()
	local removeValue = require(script.Parent.removeValue)
	local None = require(script.Parent.Parent.None)

	it("should remove the given value", function()
		local a = {1, 4, 3}
		local b = removeValue(a, 4)

		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(3)
	end)

	it("should remove all occurences of the same given value", function()
		local a = {1, 2, 2, 3}
		local b = removeValue(a, 2)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(3)
	end)

	it("should work with an empty list", function()
		local a = removeValue({}, 1)

		expect(a).to.be.a("table")
		expect(#a).to.equal(0)
	end)

	it("should work with a None element", function()
		local a = {1, 2, None, 3}
		local b = removeValue(a, 2)

		expect(#b).to.equal(3)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(None)
		expect(b[3]).to.equal(3)

		local c = removeValue(a, None)

		expect(c[3]).to.equal(3)
		expect(#c).to.equal(3)
	end)
end