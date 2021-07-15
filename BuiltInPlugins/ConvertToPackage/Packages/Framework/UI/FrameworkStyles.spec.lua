return function()
	local FrameworkStyles = require(script.Parent.FrameworkStyles)

	describe("new", function()
		it("should return a table of empty defaults", function()
			local styles = FrameworkStyles.new()
			expect(styles).to.be.ok()
			expect(type(styles)).to.equal("table")

			for _, entry in pairs(styles) do
				expect(entry.Default).to.be.ok()
				expect((next(entry.Default))).never.to.be.ok()
			end
		end)
	end)
end
