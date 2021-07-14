return function()
	local join = require(script.Parent.join)
	local None = require(script.Parent.Parent.None)

	it("should return a new table", function()
		local a = {}

		expect(join(a)).never.to.equal(a)
	end)

	it("should merge tables, overwriting previous values", function()
		local a = {
			foo = "foo-a",
			bar = "bar-a",
		}

		local b = {
			foo = "foo-b",
			baz = "baz-b",
		}

		local c = join(a, b)

		expect(c.foo).to.equal(b.foo)
		expect(c.bar).to.equal(a.bar)
		expect(c.baz).to.equal(b.baz)
	end)

	it("should remove values set to None", function()
		local a = {
			foo = "foo-a",
		}

		local b = {
			foo = None,
		}

		local c = join(a, b)

		expect(c.foo).to.equal(nil)
	end)

	it("should not mutate passed in tables", function()
		local mutationsA = 0
		local mutationsB = 0

		local a = {}
		local b = {
			foo = "foo-b",
		}

		setmetatable(a, {
			__newindex = function()
				mutationsA = mutationsA + 1
			end,
		})

		setmetatable(b, {
			__newindex = function()
				mutationsB = mutationsB + 1
			end,
		})

		join(a, b)

		expect(mutationsA).to.equal(0)
		expect(mutationsB).to.equal(0)
		expect(b.foo).to.equal("foo-b")
	end)

	it("should accept arbitrary numbers of tables", function()
		local a = {
			foo = "foo-a",
		}

		local b = {
			bar = "bar-b",
		}

		local c = {
			baz = "baz-c",
		}

		local d = join(a, b, c)

		expect(d.foo).to.equal(a.foo)
		expect(d.bar).to.equal(b.bar)
		expect(d.baz).to.equal(c.baz)
	end)

	it("should accept zero tables", function()
		expect(join()).to.be.a("table")
	end)
end