return function()
	describe("Rodux", function()
		it("should load", function()
			local Rodux = require(script.Parent)

			expect(Rodux.Store).to.be.ok()
		end)
	end)
end