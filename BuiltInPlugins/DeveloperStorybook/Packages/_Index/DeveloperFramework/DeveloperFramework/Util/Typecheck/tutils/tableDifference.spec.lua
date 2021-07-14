return function()
	local tableDifference = require(script.Parent.tableDifference)
	local expectTable = require(script.Parent.unitTests.expectTable)

	describe("WHEN given two tables", function()
		it("SHOULD return an empty table if lists are the same", function()
			local listA = {1, 2, 3}
			local listB = {1, 2, 3}

			expectTable(tableDifference(listA, listB)).toEqual({})
		end)

		it("SHOULD return a dictionary of the key value if a list has an extra value", function()
			local listA = {1, 2, 3, 4}
			local listB = {1, 2, 3}

			expectTable(tableDifference(listA, listB)).toEqual({ [4] = 4 })
		end)

		it("SHOULD return a dictionary of the key value if a dictionary has an extra value", function()
			local dictionaryA = { foo = "bar", hello = "world" }
			local dictionaryB = { foo = "bar" }

			expectTable(tableDifference(dictionaryA, dictionaryB)).toEqual({ hello = "world" })
		end)
	end)
end