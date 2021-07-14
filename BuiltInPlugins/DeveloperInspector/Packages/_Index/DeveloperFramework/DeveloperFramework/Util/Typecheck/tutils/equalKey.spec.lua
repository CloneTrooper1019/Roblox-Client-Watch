return function()
	local equalKey = require(script.Parent.equalKey)

	describe("WHEN given nil values", function()
		it("SHOULD return false", function()
			local testCase = function(tableA, tableB)
				expect(equalKey(tableA, tableB)).to.equal(false)
				expect(equalKey(tableA, tableB, "")).to.equal(false)
				expect(equalKey(tableA, tableB, "key1")).to.equal(false)
			end

			testCase(nil, nil)
			testCase(nil, {})
			testCase({}, nil)
		end)
	end)

	describe("WHEN given table values", function()
		it("SHOULD return false if key does not exist in either table (empty tables)", function()
			local tableA, tableB = {}, {}
			expect(equalKey(tableA, tableB)).to.equal(false)
			expect(equalKey(tableA, tableB, "")).to.equal(false)
			expect(equalKey(tableA, tableB, "key1")).to.equal(false)
		end)

		it("SHOULD return false if key does not exist in either table (single keys)", function()
			local tableA = {
				key1 = "value1",
			}
			local tableB = {
				key2 = "value1",
			}
			expect(equalKey(tableA, tableB)).to.equal(false)
			expect(equalKey(tableA, tableB, "")).to.equal(false)
			expect(equalKey(tableA, tableB, "key1")).to.equal(false)
		end)

		describe("WHEN key exists in both tables", function()
			it("SHOULD return true if value of key is the same", function()
				local tableA = {
					key1 = "value1",
				}
				local tableB = {
					key1 = "value1",
				}
				expect(equalKey(tableA, tableB)).to.equal(false)
				expect(equalKey(tableA, tableB, "")).to.equal(false)
				expect(equalKey(tableA, tableB, "key1")).to.equal(true)
			end)

			it("SHOULD return false if value of key is not the same", function()
				local tableA = {
					key1 = "value1",
				}
				local tableB = {
					key1 = "value2",
				}
				expect(equalKey(tableA, tableB)).to.equal(false)
				expect(equalKey(tableA, tableB, "")).to.equal(false)
				expect(equalKey(tableA, tableB, "key1")).to.equal(false)
			end)
		end)

		it("should return whether tables are equal to each other at key", function()
			local tableA = {
				key1 = "value1",
			}
			local tableB = {
				key1 = "value1",
				key2 = "value2",
			}
			expect(equalKey(tableA, tableB)).to.equal(false)
			expect(equalKey(tableA, tableB, "")).to.equal(false)
			expect(equalKey(tableA, tableB, "key1")).to.equal(true)
			expect(equalKey(tableA, tableB, "key2")).to.equal(false)
		end)
	end)
end