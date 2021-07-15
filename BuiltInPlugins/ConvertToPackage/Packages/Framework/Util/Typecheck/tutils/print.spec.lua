return function()
	local history = {}
	local mockPrint = function(...)
		local str = table.concat({ ... }, " " )
		table.insert(history, str)
	end
	local clearHistory = function()
		history = {}
	end

	local print = require(script.Parent.print)(mockPrint)

	describe("GIVEN a table", function()
		it("SHOULD handle an empty table appropriately", function()
			print({})

			local firstLine = history[1]
			expect(firstLine:sub(-1)).to.equal("{")
			local secondLine = history[2]
			expect(secondLine).to.equal("}")

			clearHistory()
		end)

		it("SHOULD handle a simple list appropriately", function()
			print({ 1, 2, 3 })

			local firstLine = history[1]
			expect(firstLine:sub(-1)).to.equal("{")
			local lastLine = history[#history]
			expect(lastLine).to.equal("}")

			local firstElement = history[2]
			expect(firstElement).to.equal("  [1] = 1,")
			local secondElement = history[3]
			expect(secondElement).to.equal("  [2] = 2,")
			local thirdElement = history[4]
			expect(thirdElement).to.equal("  [3] = 3,")

			clearHistory()
		end)

		it("SHOULD handle a simple dictionary appropriately", function()
			print({ foo = "bar", hello = "world" })

			local firstLine = history[1]
			expect(firstLine:sub(-1)).to.equal("{")
			local lastLine = history[#history]
			expect(lastLine).to.equal("}")

			local firstElement = history[2]
			expect(firstElement).to.equal("  hello = \"world\",")
			local secondElement = history[3]
			expect(secondElement).to.equal("  foo = \"bar\",")

			clearHistory()
		end)

		it("SHOULD handle a cyclic dictionary by printing a warning", function()
			local tab = {}
			tab.element1 = tab
			print(tab)

			local firstLine = history[1]
			expect(firstLine:sub(-1)).to.equal("{")
			local lastLine = history[#history]
			expect(lastLine).to.equal("}")

			local firstElement = history[2]
			local isFound = firstElement:find("Possible cycle$")
			expect(isFound).to.be.ok()

			clearHistory()
		end)
	end)

	describe("GIVEN anything else", function()
		it("SHOULD throw", function()
			expect(function()
				print(1)
			end).to.throw()

			expect(function()
				print(true)
			end).to.throw()

			expect(function()
				print("hello world")
			end).to.throw()
		end)
	end)
end