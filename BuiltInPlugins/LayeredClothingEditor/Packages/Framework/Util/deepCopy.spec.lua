return function()
	local deepEqual = require(script.Parent.deepEqual)
	local deepCopy = require(script.Parent.deepCopy)

	it("should fail when copied table and result are equal", function()
		local originalTable = {
			test = "hello"
		}

		local copy = deepCopy(originalTable)
		expect(copy).to.never.equal(originalTable)
	end)

	it("should fail when copied inner tables are equal to the original", function()
		local originalTable = {
			string = "hello",
			table = {
				inner = "test",
			}
		}

		local copy = deepCopy(originalTable)
		expect(copy.table).to.never.equal(originalTable.table)
	end)

	it("should have all values in the table and its copy be equal", function()
		local originalTable = {
			string = "hello",
			table = {
				inner = "test",
			}
		}
		local copy = deepCopy(originalTable)
		expect(deepEqual(originalTable, copy)).to.equal(true)
	end)

end