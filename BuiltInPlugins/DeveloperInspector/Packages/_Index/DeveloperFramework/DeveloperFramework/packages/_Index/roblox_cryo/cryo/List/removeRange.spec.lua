return function()
	local removeRange = require(script.Parent.removeRange)
	local None = require(script.Parent.Parent.None)

	it("should remove elements properly", function()
		local a = {1, 2, 3}
		local b = removeRange(a, 2, 2)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(3)

		local c = {1, 2, 3, 4, 5, 6}
		local d = removeRange(c, 1, 4)

		expect(#d).to.equal(2)
		expect(d[1]).to.equal(5)
		expect(d[2]).to.equal(6)

		local e = removeRange(c, 2, 5)

		expect(#e).to.equal(2)
		expect(e[1]).to.equal(1)
		expect(e[2]).to.equal(6)
	end)

	it("should throw when the start index is higher than the end index", function()
		local a = {1, 2, 3}

		expect(function()
			removeRange(a, 2, 0)
		end).to.throw()

		expect(function()
			removeRange(a, 1, -1)
		end).to.throw()
	end)

	it("should copy the table when then indexes are higher than the list length", function()
		local a = {1, 2, 3}
		local b = removeRange(a, 4, 7)

		expect(#b).to.equal(3)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(2)
		expect(b[3]).to.equal(3)
	end)

	it("should work when the start index is smaller than 1", function()
		local a = {1, 2, 3, 4}
		local b = removeRange(a, -5, 2)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(3)
		expect(b[2]).to.equal(4)
	end)

	it("should work when the end index is greater than the list length", function()
		local a = {1, 2, 3, 4}
		local b = removeRange(a, 3, 8)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(1)
		expect(b[2]).to.equal(2)
	end)

	it("should work with a None element", function()
		local a = {1, None, 3}
		local b = removeRange(a, 1, 1)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(None)
		expect(b[2]).to.equal(3)
	end)
end