return function()
	local fieldCount = require(script.Parent.fieldCount)

	describe("WHEN given empty tables", function()
		it("SHOULD return zero", function()
			expect(fieldCount({})).to.equal(0)
		end)
	end)

	describe("WHEN given a valid dictionary", function()
		it("should return table's field count", function()
			local table1 = {
				key1 = "value1",
			}
			expect(fieldCount(table1)).to.equal(1)

			local table2 = {
				key1 = "value1",
				key2 = "value2",
			}
			expect(fieldCount(table2)).to.equal(2)
		end)

		it("should return list's count", function()
			local list1 = {1, 2, 3}
			expect(fieldCount(list1)).to.equal(3)
		end)
	end)
end
