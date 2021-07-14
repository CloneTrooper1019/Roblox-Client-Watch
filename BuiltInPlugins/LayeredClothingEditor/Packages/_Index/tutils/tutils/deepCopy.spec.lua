return function()
	local deepCopy = require(script.Parent.deepCopy)
	local deepEqual = require(script.Parent.deepEqual)

	local function  deepCopyAndCompare(value)
		local aDeepCopyOfValue = deepCopy(value)
		expect(deepEqual(value, aDeepCopyOfValue)).to.equal(true)
	end

	it("SHOULD work for primitive data types", function()
		deepCopyAndCompare(true)
		deepCopyAndCompare(false)
		deepCopyAndCompare(nil)
		deepCopyAndCompare(100)
		deepCopyAndCompare("Deep Copy")
	end)

	local table1 = {
		num = 1,
		innerTable = {
			innerString = "str"
		}
	}
	local table2 = {
		num = 1,
		innerTable = {
			innerString = "str",
			innerInnerTable = table1,
		},
	}
	it("SHOULD correctly copy table without table as key ", function()
		deepCopyAndCompare(table2)

		local deepCopyOfTable2 = deepCopy(table2)

		expect(table2.innerTable).to.never.equal(deepCopyOfTable2.innerTable)
		expect(deepEqual(table2.innerTable, deepCopyOfTable2.innerTable)).to.equal(true)

		expect(table2.innerTable.innerInnerTable).to.never.equal(deepCopyOfTable2.innerTable.innerInnerTable)
		expect(deepEqual(table2.innerTable.innerInnerTable, deepCopyOfTable2.innerTable.innerInnerTable)).to.equal(true)
	end)

	local table3 = {
		[table1] = table2,
	}
	it("SHOULD correctly copy table with table as key", function()
		local deepCopyOfTable3 = deepCopy(table3)
		expect(deepEqual(table3, deepCopyOfTable3)).to.equal(false)

		local table3Key, table3Value = next(table3)
		local deepCopyOfTable3Key, deepCopyOfTable3Value = next(deepCopyOfTable3)
		expect(table3Key).to.never.equal(deepCopyOfTable3Key)
		expect(deepEqual(table3Key, deepCopyOfTable3Key)).to.equal(true)
		expect(table3Value).to.never.equal(deepCopyOfTable3Value)
		expect(deepEqual(table3Value, deepCopyOfTable3Value)).to.equal(true)
	end)

	it("SHOULD create only one copy of a table in the table", function()
		local deepCopyOfTable3 = deepCopy(table3)
		local key, value = next(deepCopyOfTable3)

		expect(key).to.never.be.equal(table1)
		expect(key).to.be.equal(value.innerTable.innerInnerTable)
		expect(deepEqual(key, value.innerTable.innerInnerTable)).to.equal(true)
	end)
end