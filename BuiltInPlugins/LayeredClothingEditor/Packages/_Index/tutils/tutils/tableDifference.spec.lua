return function()
	local tableDifference = require(script.Parent.tableDifference)
	local expectTable = require(script.Parent.unitTests.expectTable)

	describe("WHEN given two tables", function()
		it("SHOULD return an empty table if lists are the same", function()
			local listA = {1, 2, 3}
			local listB = {1, 2, 3}

			expectTable(tableDifference(listA, listB)).toEqual({})
		end)

		it("SHOULD return a dictionary of the key value if the first list has an extra value", function()
			local listA = {1, 2, 3, 4}
			local listB = {1, 2, 3}

			expectTable(tableDifference(listA, listB)).toEqual({[4] = 4})
		end)

		it("SHOULD return a dictionary of the key value if the second list has an extra value", function()
			local listA = {1, 2, 3}
			local listB = {1, 2, 3, 4}

			expectTable(tableDifference(listA, listB)).toEqual({ [4] = 4 })
		end)

		it("SHOULD return a dictionary of the key value if a dictionary has an extra value", function()
			local dictionaryA = { foo = "bar", hello = "world" }
			local dictionaryB = { foo = "bar" }

			expectTable(tableDifference(dictionaryA, dictionaryB)).toEqual({ hello = "world" })
		end)

		it("SHOULD return a dictionary of the second table's key value if the key has different value in two tables", function()
			local dictionaryA = { foo = "foo" }
			local dictionaryB = { foo = "bar" }

			expectTable(tableDifference(dictionaryA, dictionaryB)).toEqual({ foo = "bar" })
		end)

		it("SHOULD return both keys and their value if there are 2 keys with same value in 2 tables", function()
			local dictionaryA = { foo = "bar", hello = "world" }
			local dictionaryB = { bar = "bar", hello = "world" }

			expectTable(tableDifference(dictionaryA, dictionaryB)).toEqual({ foo = "bar", bar = "bar" })
		end)
	end)
end
