return function()
	local StyleValue = require(script.Parent.StyleValue)

	describe("new", function()
		it("should expect a name", function()
			expect(function()
				StyleValue.new()
			end).to.throw()
		end)

		it("should expect a themesToValuesMap", function()
			expect(function()
				StyleValue.new("Test")
			end).to.throw()
		end)

		it("should return a new StyleValue", function()
			local value = StyleValue.new("Test", {
				Light = "Light",
				Dark = "Dark",
			})
			expect(value).to.be.ok()
		end)
	end)

	describe("get", function()
		it("should get the value for the given theme", function()
			local value = StyleValue.new("Test", {
				Light = "Light",
				Dark = "Dark",
			})
			expect(value:get("Light")).to.equal("Light")
			expect(value:get("Dark")).to.equal("Dark")
			expect(value:get("NonexistentTheme")).to.equal(nil)
		end)
	end)
end