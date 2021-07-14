return function()
	local Utils = script.Parent
	local mathUtils = require(Utils.MathUtils)

	describe("Round", function()
		it("should round to specified place", function()
			local num = 101.39901
			expect(mathUtils:round(num, 0)).to.be.equal(101)
			expect(mathUtils:round(num, 1)).to.be.equal(101.4)
			expect(mathUtils:round(num, 2)).to.be.equal(101.40)
			expect(mathUtils:round(num, 3)).to.be.equal(101.399)
			expect(mathUtils:round(num, 4)).to.be.equal(101.3990)
		end)

		it("round should work for negative numbers", function()
			local num = -0.99095
			expect(mathUtils:round(num, 0)).to.be.equal(-1)
			expect(mathUtils:round(num, 1)).to.be.equal(-1)
			expect(mathUtils:round(num, 2)).to.be.equal(-0.99)
			expect(mathUtils:round(num, 3)).to.be.equal(-0.991)
			expect(mathUtils:round(num, 4)).to.be.equal(-0.9909)
		end)
	end)

	describe("Fuzzy Equals", function()
		it("fuzzyEq should work with no epsilon provided", function()
			expect(mathUtils:fuzzyEq(2.00009, 2)).to.be.equal(true)
			expect(mathUtils:fuzzyEq(2, 2)).to.be.equal(true)
			expect(mathUtils:fuzzyEq(2, 3)).to.be.equal(false)
			expect(mathUtils:fuzzyEq(mathUtils.NEAR_ZERO, 0)).to.be.equal(false)
		end)

		it("fuzzyEq should work with supplied epsilon value", function()
			expect(mathUtils:fuzzyEq(2.0000009, 2, 0.000001)).to.be.equal(true)
			expect(mathUtils:fuzzyEq(2, 2, 0.1)).to.be.equal(true)
			expect(mathUtils:fuzzyEq(2, 3, 0.01)).to.be.equal(false)
			expect(mathUtils:fuzzyEq(0.00000001, 0, 0.00000001)).to.be.equal(false)
		end)
	end)
end