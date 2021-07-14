return function()
	local deepEqual = require(script.Parent.deepEqual)

	it("SHOULD work for primitive data types", function()
		expect(deepEqual(1, 1)).to.equal(true)
		expect(deepEqual("str1", "str1")).to.equal(true)
		expect(deepEqual(1, 2)).to.equal(false)
		expect(deepEqual("str1", "str2")).to.equal(false)
		expect(deepEqual(nil, nil)).to.equal(true)
		expect(deepEqual(nil, false)).to.equal(false)
	end)

	it("SHOULD correctly identifies deeply-equal tables", function()
		local table1 = {
			num = 1,
			innerTable = {
				innerString = "str"
			}
		}
		local table2 = {
			num = 1,
			innerTable = {
				innerString = "str"
			}
		}
		expect(deepEqual(table1, table2)).to.equal(true)
	end)

	it("SHOULD correctly rejects non-deeply-equal tables", function()
		local table1 = {
			num = 1,
			innerTable = {
				innerString = "str"
			}
		}
		local table2 = {
			num = 1,
			innerTable = {
				innerString = "differentStr"
			}
		}
		expect(deepEqual(table1, table2)).to.equal(false)
		local table3 = {
			num = 1,
			innerTable = {
				innerString = "str"
			}
		}
		local table4 = {
			num = 1,
			innerTableWithDifferentKey = {
				innerString = "str"
			}
		}
		expect(deepEqual(table3, table4)).to.equal(false)
	end)
end