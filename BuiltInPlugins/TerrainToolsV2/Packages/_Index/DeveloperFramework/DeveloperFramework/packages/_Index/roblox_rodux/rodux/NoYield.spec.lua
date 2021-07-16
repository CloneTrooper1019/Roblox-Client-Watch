return function()
	local NoYield = require(script.Parent.NoYield)

	it("should call functions normally", function()
		local callCount = 0

		local function test(a, b)
			expect(a).to.equal(5)
			expect(b).to.equal(6)

			callCount = callCount + 1

			return 11, "hello"
		end

		local a, b = NoYield(test, 5, 6)

		expect(a).to.equal(11)
		expect(b).to.equal("hello")
	end)

	it("should throw on yield", function()
		local preCount = 0
		local postCount = 0

		local function testMethod()
			preCount = preCount + 1
			wait()
			postCount = postCount + 1
		end

		local ok, err = pcall(NoYield, testMethod)

		expect(preCount).to.equal(1)
		expect(postCount).to.equal(0)

		expect(ok).to.equal(false)
		expect(err:find("Attempted to yield inside changed event!")).to.be.ok()
		expect(err:find("NoYield.spec")).to.be.ok()
	end)

	it("should propagate error messages", function()
		local count = 0

		local function test()
			count = count + 1
			error("foo")
		end

		local ok, err = pcall(NoYield, test)

		expect(ok).to.equal(false)
		expect(err:find("foo")).to.be.ok()
		expect(err:find("NoYield.spec")).to.be.ok()
	end)
end