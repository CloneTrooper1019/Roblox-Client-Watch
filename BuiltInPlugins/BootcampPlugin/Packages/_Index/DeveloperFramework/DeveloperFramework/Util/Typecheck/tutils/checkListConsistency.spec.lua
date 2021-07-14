return function()
	local checkListConsistency = require(script.Parent.checkListConsistency)

	describe("WHEN given a valid table", function()
		it("SHOULD return true for lists", function()
			expect(checkListConsistency({ 1, 2, 3 })).to.equal(true)
		end)

		it("SHOULD return false for lists with holes", function()
			local list = {
				[1] = true,
				[2] = nil,
				[3] = true,
			}
			expect(checkListConsistency(list)).to.equal(false)
		end)

		it("SHOULD return true for dictionary with string keys", function()
			local dictionary = {
				foo = "bar",
				hello = "world",
			}
			expect(checkListConsistency(dictionary)).to.equal(true)
		end)

		it("SHOULD return false for dictionary with mixed keys", function()
			local dictionary = {
				foo = "bar",
				[100] = "hundred",
			}
			expect(checkListConsistency(dictionary)).to.equal(false)
		end)

		it("SHOULD return false for dictionary with keys that are not a string or number", function()
			local dictionary = {
				[{}] = true,
			}
			expect(checkListConsistency(dictionary)).to.equal(false)
		end)
	end)
end