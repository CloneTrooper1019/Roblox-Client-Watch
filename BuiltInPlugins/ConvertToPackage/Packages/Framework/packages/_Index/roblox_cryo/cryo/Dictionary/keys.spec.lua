return function()
	local keys = require(script.Parent.keys)
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

		keys(a)

		for key, value in pairs(a) do
			expect(aCopy[key]).to.equal(value)
		end
		for key, value in pairs(aCopy) do
			expect(a[key]).to.equal(value)
		end
	end)

	it("should return the correct keys", function()
		local a = {
			Foo = "FooValue",
			Bar = "BarValue",
			Test = "TestValue"
		}
		local keyCount = {
			Foo = 1,
			Bar = 1,
			Test = 1
		}
		local b = keys(a)

		expect(#b).to.equal(3)
		for _, key in ipairs(b) do
			expect(keyCount[key]).never.to.equal(nil)
			keyCount[key] = keyCount[key] - 1
		end
		for _, count in pairs(keyCount) do
			expect(count).to.equal(0)
		end
	end)

	it("should work with an empty table", function()
		local a = keys({})

		expect(next(a)).to.equal(nil)
	end)

	it("should contain a None element if there is a None key in the dictionary", function()
		local a = {
			[None] = "Foo",
			Bar = "BarValue"
		}
		local keyCount = {
			[None] = 1,
			Bar = 1
		}
		local b = keys(a)

		expect(#b).to.equal(2)
		for _, key in ipairs(b) do
			expect(keyCount[key]).never.to.equal(nil)
			keyCount[key] = keyCount[key] - 1
		end
		for _, count in pairs(keyCount) do
			expect(count).to.equal(0)
		end
	end)
end