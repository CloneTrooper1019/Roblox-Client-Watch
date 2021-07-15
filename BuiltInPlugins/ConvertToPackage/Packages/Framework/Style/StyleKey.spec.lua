return function()
	local StyleKey = require(script.Parent.StyleKey)

	describe("add", function()
		it("should coerce to the given name", function()
			local symbol = StyleKey:add("foo")

			expect((tostring(symbol):find("foo"))).to.be.ok()
		end)

		it("should create a new entry when there is no current entry found", function()
			local testA = StyleKey["abc"]
			expect(testA).never.to.equal(nil)
		end)

		it("should not have duplicate entries", function()
			local testA = StyleKey:add("abc")
			local testB = StyleKey:add("abc")
			expect(testA).to.equal(testB)
		end)

		it("should get the same entry for the same lookup", function()
			local testA = StyleKey["abc"]
			local testB = StyleKey["abc"]
			expect(testA).to.equal(testB)
		end)

		it("should have StyleKey as a metavalue", function()
			local testA = StyleKey["abc"]
			local mt = getmetatable(testA)
			expect(mt).to.equal(StyleKey)
		end)
	end)
end
