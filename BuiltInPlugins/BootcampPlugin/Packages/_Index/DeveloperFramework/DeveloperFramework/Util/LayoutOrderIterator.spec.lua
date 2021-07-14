return function()
	local LayoutOrderIterator = require(script.Parent.LayoutOrderIterator)

	describe("new", function()
		it("should construct from nothing", function()
			local orderIterator = LayoutOrderIterator.new()
			
			expect(orderIterator).to.be.ok()
		end)
	end)

	describe("getNextOrder", function()
		it("should correctly generate the next order", function()
			local orderIterator = LayoutOrderIterator.new()

			expect(orderIterator:getNextOrder()).to.be.equal(1)
			expect(orderIterator:getNextOrder()).to.be.equal(2)
			expect(orderIterator:getNextOrder()).to.be.equal(3)
		end)

		it("should correctly generate the next order when more than one iterators are created", function()
			local orderIterator1 = LayoutOrderIterator.new()
			local orderIterator2 = LayoutOrderIterator.new()

			expect(orderIterator1:getNextOrder()).to.be.equal(1)
			expect(orderIterator2:getNextOrder()).to.be.equal(1)
		end)
	end)
end