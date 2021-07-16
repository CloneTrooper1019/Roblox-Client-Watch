return function()
	local toSet = require(script.Parent.toSet)

	it("should return a new table", function()
		local a = {1, 2, 3}

		expect(toSet(a)).never.to.equal(a)
	end)

	it("should not mutate the given table", function()
		local a = {"a", "b", "c"}
		toSet(a)

		for k, v in pairs(a) do
			if k == 1 then
				expect(v).to.equal("a")
			elseif k == 2 then
				expect(v).to.equal("b")
			elseif k == 3 then
				expect(v).to.equal("c")
			else
				error("Extra key was added to table a")
			end
		end
	end)

	it("should have every value in a as a key mapped to true in b", function()
		local a = {1, 2, 3, "a", "b", "c"}
		local b = toSet(a)

		expect(#b).to.equal(3)
		expect(b[1]).to.equal(true)
		expect(b[2]).to.equal(true)
		expect(b[3]).to.equal(true)

		expect(b[4]).to.equal(nil)

		expect(b["a"]).to.equal(true)
		expect(b["b"]).to.equal(true)
		expect(b["c"]).to.equal(true)
	end)
end