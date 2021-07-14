return function()
	local reverse = require(script.Parent.reverse)

	it("should return a new table", function()
		local a = {1, 2, 3}

		expect(reverse(a)).never.to.equal(a)
	end)

	it("should not mutate the given table", function()
		local a = {1, 2, 3}
		reverse(a)

		expect(#a).to.equal(3)
		expect(a[1]).to.equal(1)
		expect(a[2]).to.equal(2)
		expect(a[3]).to.equal(3)
	end)

	it("should contain the same elements", function()
		local a = {
			"Foo",
			"Bar"
		}
		local aSet = {
			Foo = true,
			Bar = true
		}
		local b = reverse(a)

		expect(#b).to.equal(2)
		for _, value in ipairs(b) do
			expect(aSet[value]).to.equal(true)
		end
	end)

	it("should reverse the list", function()
		local a = {1, 2, 3, 4}
		local b = reverse(a)

		expect(b[1]).to.equal(4)
		expect(b[2]).to.equal(3)
		expect(b[3]).to.equal(2)
		expect(b[4]).to.equal(1)
	end)
end