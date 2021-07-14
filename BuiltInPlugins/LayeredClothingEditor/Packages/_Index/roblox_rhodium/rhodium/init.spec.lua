return function()
	describe("Rhodium", function()
		it("should load", function()
			local Rhodium = require(script.Parent)

			expect(Rhodium).to.be.ok()
			expect(Rhodium.Element).to.be.ok()
			expect(Rhodium.XPath).to.be.ok()
			expect(Rhodium.VirtualInput).to.be.ok()
		end)
	end)
end