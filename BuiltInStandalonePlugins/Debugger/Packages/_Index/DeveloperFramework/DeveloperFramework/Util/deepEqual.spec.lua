return function()
	local deepEqual = require(script.Parent.deepEqual)

	it("should fail when args are not equal", function()
		expect(deepEqual(1, 2)).to.equal(false)

		expect(deepEqual({
			foo = 1,
		}, {
			foo = 2,
		})).to.equal(false)
	end)

	it("should compare non-table values using standard '==' equality", function()
		expect(deepEqual(1, 1)).to.equal(true)
		expect(deepEqual("hello", "hello")).to.equal(true)
		expect(deepEqual(nil, nil)).to.equal(true)

		local someFunction = function() end
		local theSameFunction = someFunction

		expect(deepEqual(someFunction, theSameFunction)).to.equal(true)

		local A = {
			foo = someFunction
		}
		local B = {
			foo = theSameFunction
		}

		expect(deepEqual(A, B)).to.equal(true)
	end)

	it("should fail when types differ", function()
		expect(deepEqual(1, "1")).to.equal(false)
	end)

	it("should compare tables", function()
		expect(deepEqual({1, 2, 3}, {1, 2, 3})).to.equal(true)
		expect(deepEqual({1, 2, 3, nil}, {1, 2, 3})).to.equal(true)
		expect(deepEqual({1, 2, 3}, {1, 3, 3})).to.equal(false)
	end)

	it("should compare nested tables", function()
		local A = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			}
		}
		local B = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2,
			}
		}

		expect(deepEqual(A, B)).to.equal(true)

		local C = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 3,
			}
		}

		expect(deepEqual(A, C)).to.equal(false)
	end)

	it("should be commutative", function()
		local equalArgsA = {
			foo = "bar",
			hello = "world",
		}
		local equalArgsB = {
			foo = "bar",
			hello = "world",
		}

		expect(deepEqual(equalArgsA, equalArgsB)).to.equal(true)
		expect(deepEqual(equalArgsB, equalArgsA)).to.equal(true)


		local nonEqualArgs = {
			foo = "bar",
		}

		expect(deepEqual(equalArgsA, nonEqualArgs)).to.equal(false)
		expect(deepEqual(nonEqualArgs, equalArgsA)).to.equal(false)
	end)
end