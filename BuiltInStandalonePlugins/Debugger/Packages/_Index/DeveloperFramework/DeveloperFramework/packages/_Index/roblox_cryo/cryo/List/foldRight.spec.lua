return function()
	local foldRight = require(script.Parent.foldRight)

	it("should call the callback", function()
		local a = {1, 2, 3}
		local called = 0

		foldRight(a, function()
			called = called + 1
		end, 0)

		expect(called).to.equal(3)
	end)

	it("should not call the callback when the list is empty", function()
		local called = false

		foldRight({}, function()
			called = true
		end, 0)

		expect(called).to.equal(false)
	end)

	it("should call the callback for each element", function()
		local a = {4, 5, 6}
		local copy = {}

		foldRight(a, function(accum, value, index)
			copy[index] = value
			return accum
		end, 0)

		expect(#copy).to.equal(#a)

		for key, value in pairs(a) do
			expect(value).to.equal(copy[key])
		end
	end)

	it("should pass the same modified initial value to the callback", function()
		local a = {5, 4, 3}
		local initialValue = {}

		foldRight(a, function(accum)
			expect(accum).to.equal(initialValue)
			return accum
		end, initialValue)
	end)

	it("should call the callback in the correct order", function()
		local a = {5, 4, 3}
		local index = 3

		foldRight(a, function(accum, value)
			expect(value).to.equal(a[index])
			index = index - 1
			return accum
		end, 0)
	end)
end