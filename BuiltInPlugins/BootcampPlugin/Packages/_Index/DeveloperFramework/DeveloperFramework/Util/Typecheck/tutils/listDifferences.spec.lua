return function()
	local listDifferences = require(script.Parent.listDifferences)
	local expectTable = require(script.Parent.unitTests.expectTable)

	describe("GIVEN two tables", function()
		describe("WHEN the tables are lists", function()
			it("SHOULD return an empty table if the lists share the same values", function()
				local listA = { 1, 2, 3 }
				local listB = { 1, 2, 3 }
				expectTable(listDifferences(listA, listB)).toEqual({})
			end)

			it("SHOULD return a list of delta values if first parameter has extra values", function()
				local listA = { 1, 2, 3, 4 }
				local listB = { 1, 2, 3 }
				expectTable(listDifferences(listA, listB)).toEqual({ 4 })
			end)

			it("SHOULD return an empty table if the second parameter has extra values", function()
				local listA = { 1, 2, 3 }
				local listB = { 1, 2, 3, 4 }
				expectTable(listDifferences(listA, listB)).toEqual({})
			end)
		end)

		describe("WHEN the tables are dictionaries", function()
			it("SHOULD always return an empty table (same dictionaries)", function()
				local dictionaryA = { foo = "bar" }
				local dictionaryB = { foo = "bar" }
				expectTable(listDifferences(dictionaryA, dictionaryB)).toEqual({})
			end)

			it("SHOULD always return an empty table (second has extra keys)", function()
				local dictionaryA = { foo = "bar" }
				local dictionaryB = { foo = "bar", hello = "world" }
				expectTable(listDifferences(dictionaryA, dictionaryB)).toEqual({})
			end)

			it("SHOULD always return an empty table (first has extra keys)", function()
				local dictionaryA = { foo = "bar" }
				local dictionaryB = { foo = "bar", hello = "world" }
				expectTable(listDifferences(dictionaryA, dictionaryB)).toEqual({})
			end)
		end)
	end)
end