return function()
	local toString = require(script.Parent.toString)

	describe("WHEN given a table", function()
		it("SHOULD handle simple lists", function()
			local indent = "."
			local result = toString({ 1, 2, 3 }, indent)

			expect(result).to.equal("{\n  .1,\n  .2,\n  .3,\n.}")
		end)

		it("SHOULD handle simple dictionaries", function()
			local indent = "."
			local result = toString({ hello = "world" }, indent)

			expect(result).to.equal("{\n  .hello = world;\n.}")
		end)

		it("SHOULD handle tables within tables", function()
			local indent = "."
			local result = toString({ {} }, indent)

			expect(result).to.equal("{\n  .{\n  .},\n.}")
		end)

		it("SHOULD show a warning for mixed tables", function()
			local result = toString({ 1, 2, hello = "world" })
			local findResult = result:find("WARNING: this table fails the list consistency test")
			expect(findResult).to.be.ok()
		end)
	end)

	describe("WHEN given anything else", function()
		it("SHOULD return the tostring equivalent", function()
			expect(toString(1)).to.equal(tostring(1))
			expect(toString(true)).to.equal(tostring(true))
			expect(toString("hello")).to.equal(tostring("hello"))
		end)
	end)
end