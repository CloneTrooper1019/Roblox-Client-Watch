return function()
	local map = require(script.Parent.map)

	it("should return a new table", function()
		local a = {1, 2, 3}

		expect(map(a, function() end)).never.to.equal(a)
	end)

	it("should call the callback for each element", function()
		local a = {5, 6, 7}
		local copy = {}
		map(a, function(value, index)
			copy[index] = value
			return value
		end)

		for key, value in pairs(a) do
			expect(copy[key]).to.equal(value)
		end

		for key, value in pairs(copy) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should copy list", function()
		local a = {1, 2, 3}
		local b = map(a, function(value)
			return value
		end)

		for key, value in pairs(a) do
			expect(b[key]).to.equal(value)
		end

		for key, value in pairs(b) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should sets the new values to the result of the given callback", function()
		local a = {5, 6, 7}
		local b = map(a, function(value)
			return value * 2
		end)

		expect(#b).to.equal(#a)
		for i = 1, #a do
			expect(b[i]).to.equal(a[i] * 2)
		end
	end)

	it("should work with an empty list", function()
		local a = {}
		local b = map(a, function() end)

		expect(b).to.be.a("table")
		expect(b).never.to.equal(a)
	end)
end