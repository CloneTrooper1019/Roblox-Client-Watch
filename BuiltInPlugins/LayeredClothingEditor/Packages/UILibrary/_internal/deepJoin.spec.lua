return function()
	local Library = script.Parent
	local deepJoin = require(Library.deepJoin)

	it("should join two tables together", function()
		local tableA = {key1 = "Value1"}
		local tableB = {key2 = "Value2"}

		local result = deepJoin(tableA, tableB)

		expect(result.key1).to.equal("Value1")
		expect(result.key2).to.equal("Value2")
	end)

	it("should add all the entries from the first table", function()
		local tableA = {key1 = "Value1", key2 = "Value2"}
		local tableB = {}

		local result = deepJoin(tableA, tableB)

		expect(result.key1).to.equal("Value1")
		expect(result.key2).to.equal("Value2")
	end)

	it("should add all the entries from the second table", function()
		local tableA = {}
		local tableB = {key1 = "Value1", key2 = "Value2"}

		local result = deepJoin(tableA, tableB)

		expect(result.key1).to.equal("Value1")
		expect(result.key2).to.equal("Value2")
	end)

	it("should join values in nested tables", function()
		local tableA = {
			set = {
				key1 = "Value1",
			},
		}

		local tableB = {
			set = {
				key2 = "Value2",
			},
		}

		local result = deepJoin(tableA, tableB)

		expect(result.set).to.be.ok()
		expect(result.set.key1).to.equal("Value1")
		expect(result.set.key2).to.equal("Value2")
	end)

	it("should prioritize the second table if values overlap", function()
		local tableA = {
			outsideKey = "Old",
			set = {
				insideKey = "Old",
			},
		}

		local tableB = {
			outsideKey = "New",
			set = {
				insideKey = "New",
			},
		}

		local result = deepJoin(tableA, tableB)

		expect(result.outsideKey).to.equal("New")
		expect(result.set).to.be.ok()
		expect(result.set.insideKey).to.equal("New")
	end)
end