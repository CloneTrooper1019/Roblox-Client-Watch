return function()
	local values = require(script.Parent.values)
	local None = require(script.Parent.Parent.None)

	it("should not mutate the given table", function()
		local a = {
			Foo = "FooValue",
			Bar = "BarValue"
		}
		local aCopy = {
			Foo = "FooValue",
			Bar = "BarValue"
		}

		values(a)

		for key, value in pairs(a) do
			expect(aCopy[key]).to.equal(value)
		end
		for key, value in pairs(aCopy) do
			expect(a[key]).to.equal(value)
		end
	end)

	it("should return the correct values", function()
		local a = {
			Foo = "FooValue",
			Bar = "BarValue",
			Test = "TestValue"
		}
		local valueCount = {
			FooValue = 1,
			BarValue = 1,
			TestValue = 1
		}
		local b = values(a)

		expect(#b).to.equal(3)
		for _, value in ipairs(b) do
			expect(valueCount[value]).never.to.equal(nil)
			valueCount[value] = valueCount[value] - 1
		end
		for _, count in pairs(valueCount) do
			expect(count).to.equal(0)
		end
	end)

	it("should return duplicates if two values are the same", function()
		local a = {
			Foo = "FooValue",
			Bar = "BarValue",
			Test = "FooValue"
		}
		local valueCount = {
			FooValue = 2,
			BarValue = 1,
		}
		local b = values(a)

		expect(#b).to.equal(3)
		for _, value in ipairs(b) do
			expect(valueCount[value]).never.to.equal(nil)
			valueCount[value] = valueCount[value] - 1
		end
		for _, count in pairs(valueCount) do
			expect(count).to.equal(0)
		end
	end)

	it("should work with an empty table", function()
		local a = values({})

		expect(next(a)).to.equal(nil)
	end)

	it("should contain a None element if there is a None value in the dictionary", function()
		local a = {
			Foo = None,
			Bar = "BarValue"
		}
		local valueCount = {
			[None] = 1,
			BarValue = 1
		}
		local b = values(a)

		expect(#b).to.equal(2)
		for _, value in ipairs(b) do
			expect(valueCount[value]).never.to.equal(nil)
			valueCount[value] = valueCount[value] - 1
		end
		for _, count in pairs(valueCount) do
			expect(count).to.equal(0)
		end
	end)
end