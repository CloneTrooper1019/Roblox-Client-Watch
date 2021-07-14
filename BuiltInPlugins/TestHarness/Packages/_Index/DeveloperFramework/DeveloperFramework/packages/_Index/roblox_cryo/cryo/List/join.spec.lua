return function()
	local join = require(script.Parent.join)
	local None = require(script.Parent.Parent.None)

	it("should return a new table", function()
		local a = {}

		expect(join(a)).never.to.equal(a)
	end)

	it("should remove elements equal to None", function()
		local a = {
			"foo-a"
		}

		local b = {
			None,
			"foo-b"
		}

		local c = join(a, b)

		expect(c[1]).to.equal("foo-a")
		expect(c[2]).to.equal("foo-b")
		expect(c[3]).to.equal(nil)
	end)

	it("should accept arbitrary numbers of tables", function()
		local a = {1}
		local b = {2}
		local c = {3}

		local d = join(a, b, c)

		expect(#d).to.equal(3)
		expect(d[1]).to.equal(1)
		expect(d[2]).to.equal(2)
		expect(d[3]).to.equal(3)
	end)

	it("should accept zero tables", function()
		expect(join()).to.be.a("table")
	end)
end