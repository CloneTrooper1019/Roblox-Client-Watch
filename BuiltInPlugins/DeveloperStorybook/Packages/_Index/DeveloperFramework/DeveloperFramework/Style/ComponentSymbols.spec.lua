return function()
	local ComponentSymbols = require(script.Parent.ComponentSymbols)

	local function cleanUpSymbols(symbolName)
		for k,_ in pairs(ComponentSymbols) do
			if typeof(k) == "table" then
				ComponentSymbols[k] = nil
			end
		end
	end

	describe("add", function()
		afterEach(function()
			cleanUpSymbols()
		end)

		it("should coerce to the given name", function()
			local symbol = ComponentSymbols:add("foo")
			expect((tostring(symbol):find("foo"))).to.be.ok()
		end)

		it("should not have duplicate entries", function()
			local testA = ComponentSymbols:add("abc")
			local testB = ComponentSymbols:add("abc")
			expect(testA).to.equal(testB)
		end)

		it("should get the same entry for the same lookup", function()
			ComponentSymbols:add("abc")
			ComponentSymbols:add("abc")
			local testA = ComponentSymbols["abc"]
			local testB = ComponentSymbols["abc"]
			expect(testA).to.equal(testB)
		end)

		it("should have ComponentSymbols as a metavalue", function()
			ComponentSymbols:add("abc")
			local testA = ComponentSymbols["abc"]
			local mt = getmetatable(testA)
			expect(mt).to.equal(ComponentSymbols)
		end)
	end)
end
