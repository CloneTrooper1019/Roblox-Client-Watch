return function()
	local tableCache = require(script.Parent.tableCache)
	local TABLE_CACHE_NAME = "tableCacheTest"

	describe("add", function()
		it("should coerce to the given name", function()
			local symbol = tableCache(TABLE_CACHE_NAME):add("foo")
			expect((tostring(symbol):find("foo"))).to.be.ok()
		end)

		it("should have table entires", function()
			local cache = tableCache(TABLE_CACHE_NAME)
			local testA = cache:add("abc")
			expect(typeof(testA)).to.equal("table")
			expect(tostring(testA)).to.equal("tableCacheTest(abc)")
		end)

		it("should not have duplicate entries", function()
			local cache = tableCache(TABLE_CACHE_NAME .. "new")
			local testA = cache:add("abc")
			local testB = cache:add("abc")
			expect(testA).to.equal(testB)

			local count = 0
			for _,v in pairs(cache) do
				if typeof(v) ~= "function" then
					count = count + 1
				end
			end
			expect(count).to.equal(1)
		end)

		it("should get the same entry for the same lookup", function()
			local cache = tableCache(TABLE_CACHE_NAME)
			local testA = cache["abc"]
			local testB = cache["abc"]
			expect(testA).to.equal(testB)
		end)
	end)
end
