return function()
	local Util = script.Parent
	local Math = require(Util.Math)

	describe("round", function()
		it("should round to specified place", function()
			local num = 101.39901
			expect(Math.round(num, 0)).to.be.equal(101)
			expect(Math.round(num, 1)).to.be.equal(101.4)
			expect(Math.round(num, 2)).to.be.equal(101.40)
			expect(Math.round(num, 3)).to.be.equal(101.399)
			expect(Math.round(num, 4)).to.be.equal(101.3990)
		end)

		it("round should work for negative numbers", function()
			local num = -0.99095
			expect(Math.round(num, 0)).to.be.equal(-1)
			expect(Math.round(num, 1)).to.be.equal(-1)
			expect(Math.round(num, 2)).to.be.equal(-0.99)
			expect(Math.round(num, 3)).to.be.equal(-0.991)
			expect(Math.round(num, 4)).to.be.equal(-0.9909)
		end)
	end)

	describe("isNaN", function()
		it("returns true", function()
			expect(Math.isNaN(0/0)).to.equal(true)
		end)

		it("returns false", function()
			expect(Math.isNaN(1/0)).to.equal(false)
		end)
	end)

	describe("fuzzyEq", function()
		it("fuzzyEq should work with no epsilon provided", function()
			expect(Math.fuzzyEq(2.00009, 2)).to.be.equal(true)
			expect(Math.fuzzyEq(2, 2)).to.be.equal(true)
			expect(Math.fuzzyEq(2, 3)).to.be.equal(false)
			expect(Math.fuzzyEq(Math.NEAR_ZERO, 0)).to.be.equal(false)
		end)

		it("fuzzyEq should work with supplied epsilon value", function()
			expect(Math.fuzzyEq(2.0000009, 2, 0.000001)).to.be.equal(true)
			expect(Math.fuzzyEq(2, 2, 0.1)).to.be.equal(true)
			expect(Math.fuzzyEq(2, 3, 0.01)).to.be.equal(false)
			expect(Math.fuzzyEq(0.00000001, 0, 0.00000001)).to.be.equal(false)
		end)
	end)
end