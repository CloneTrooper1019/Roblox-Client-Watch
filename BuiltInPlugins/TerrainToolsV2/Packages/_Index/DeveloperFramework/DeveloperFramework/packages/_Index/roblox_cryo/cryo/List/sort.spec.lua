return function()
	local sort = require(script.Parent.sort)

	it("should return a new table", function()
		local a = {}

		expect(sort(a)).never.to.equal(a)
	end)

	it("should not mutate the given table", function()
		local a = {77, "foo", 2}
		local function order(first, second)
			return tostring(first) < tostring(second)
		end
		sort(a, order)

		expect(#a).to.equal(3)
		expect(a[1]).to.equal(77)
		expect(a[2]).to.equal("foo")
		expect(a[3]).to.equal(2)
	end)

	it("should contain the same elements from the given table", function()
		local a = {
			"Foo",
			"Bar",
			"Test"
		}
		local elementSet = {
			Foo = true,
			Bar = true,
			Test = true
		}
		local b = sort(a)

		expect(#b).to.equal(3)
		for _, value in ipairs(b) do
			expect(elementSet[value]).to.equal(true)
		end
	end)

	it("should sort with the default table.sort when no callback is given", function()
		local a = {4, 2, 5, 3, 1}
		local b = sort(a)

		table.sort(a)

		expect(#b).to.equal(#a)
		for i = 1, #a do
			expect(b[i]).to.equal(a[i])
		end
	end)

	it("should sort with the given callback", function()
		local a = {1, 2, 5, 3, 4}
		local function order(first, second)
			return first > second
		end
		local b = sort(a, order)

		table.sort(a, order)

		expect(#b).to.equal(#a)
		for i = 1, #a do
			expect(b[i]).to.equal(a[i])
		end
	end)

	it("should work with an empty table", function()
		local a = sort({})

		expect(#a).to.equal(0)
	end)
end