return function()
	local shallowEqual = require(script.Parent.shallowEqual)

	it("should compare dictionaries", function()
		local a = {
			a = "a",
			b = {},
			c = 6,
		}

		local b = {
			b = a.b,
			c = a.c,
			a = a.a,
		}

		local c = {
			b = {},
			a = a.a,
			c = a.c,
		}

		local d = {
			a = a.a,
			b = a.b,
			c = a.c,
			d = "hello",
		}

		expect(shallowEqual(a, a)).to.equal(true)
		expect(shallowEqual(a, b)).to.equal(true)
		expect(shallowEqual(a, c)).to.equal(false)
		expect(shallowEqual(b, c)).to.equal(false)
		expect(shallowEqual(a, d)).to.equal(false)
		expect(shallowEqual(b, d)).to.equal(false)
	end)

	it("should handle nil for either argument", function()
		local a = {}

		expect(shallowEqual(nil, nil)).to.equal(true)
		expect(shallowEqual(a, nil)).to.equal(false)
		expect(shallowEqual(nil, a)).to.equal(false)
	end)
end