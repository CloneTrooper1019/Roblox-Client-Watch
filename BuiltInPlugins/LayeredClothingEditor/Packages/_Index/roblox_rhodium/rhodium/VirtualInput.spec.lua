return function()
	describe("VirtualInput", function()
		it("should load", function()
			local VirtualInput = require(script.Parent.VirtualInput)

			expect(VirtualInput).to.be.ok()
			expect(VirtualInput.Keyboard).to.be.ok()
			expect(VirtualInput.Mouse).to.be.ok()
			expect(VirtualInput.Touch).to.be.ok()
			expect(VirtualInput.GamePad).to.be.ok()
			expect(VirtualInput.Text).to.be.ok()
		end)
	end)
end