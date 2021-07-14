return function()
	local enumerate = require(script.Parent.enumerate)

	describe("Any Enum", function()
		local AnyEnum = enumerate("AnyEnum", { "A", "B", "C" })

		it("should be valid", function()
			expect(AnyEnum).to.be.ok()
		end)

		it("should have the correct name", function()
			expect(tostring(AnyEnum)).to.be.equal("AnyEnum")
		end)

		it("cannot be altered", function()
			expect(function()
				AnyEnum.A = "B"
			end).to.throw()
		end)

		it("should error when accessing an invalid value", function()
			expect(function()
				local _ = AnyEnum.D
			end).to.throw()
		end)

		it("should have values that can be compared for equality", function()
			expect(AnyEnum.A).to.equal(AnyEnum.A)
			expect(AnyEnum.A == AnyEnum.B).to.equal(false)
		end)

		it("should have userdata values", function()
			expect(typeof(AnyEnum.A)).to.equal("userdata")
		end)

		it("should have values with correct rawValue types", function()
			expect(typeof(AnyEnum.A.rawValue())).to.equal("string")
		end)

		it("should have values with a useful name", function()
			expect(tostring(AnyEnum.A)).to.equal("AnyEnum.A")
		end)

		it("should have values with correct rawValues", function()
			expect(AnyEnum.A.rawValue()).to.equal("A")
		end)

		it("should return the correct value from a rawValue", function()
			expect(AnyEnum.fromRawValue("A")).to.equal(AnyEnum.A)
		end)

		it("should detect whether a value is an enum value", function()
			expect(AnyEnum.isEnumValue(AnyEnum.A)).to.equal(true)
			expect(AnyEnum.isEnumValue("A")).to.equal(false)
		end)
	end)

	it("should error when creating an enum with a non-string name", function()
		expect(function()
			enumerate(1, { "A", "B", "C" })
		end).to.throw()
	end)

	it("should error when creating an enum with duplicate values", function()
		expect(function()
			enumerate(1, { "A", "B", "C", "C" })
		end).to.throw()
	end)
end