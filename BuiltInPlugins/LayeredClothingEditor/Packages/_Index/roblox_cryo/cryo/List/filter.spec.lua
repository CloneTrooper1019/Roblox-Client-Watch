return function()
	local filter = require(script.Parent.filter)

	it("should call the callback for each element", function()
		local a = {
			"foo1",
			"foo2",
			"foo3"
		}
		local copy = {}
		local function copyCallback(value, index)
			copy[index] = value
			return true
		end
		filter(a, copyCallback)

		for key, value in pairs(a) do
			expect(copy[key]).to.equal(value)
		end

		for key, value in pairs(copy) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should correctly use the filter callback", function()
		local a = {1, 2, 3, 4, 5}
		local function evenOnly(value)
			return value % 2 == 0
		end
		local b = filter(a, evenOnly)

		expect(#b).to.equal(2)
		expect(b[1]).to.equal(2)
		expect(b[2]).to.equal(4)
	end)

	it("should copy the list correctly", function()
		local a = {1, 2, 3}
		local function keepAll()
			return true
		end
		local b = filter(a, keepAll)

		expect(b).never.to.equal(a)

		for key, value in pairs(a) do
			expect(b[key]).to.equal(value)
		end

		for key, value in pairs(b) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should work with an empty table", function()
		local called = false
		local function callback()
			called = true
			return true
		end
		local a = filter({}, callback)

		expect(#a).to.equal(0)
		expect(called).to.equal(false)
	end)

	it("should remove all element from a list when callback return always false", function()
		local a = {6, 2, 8, 6, 7}
		local function removeAll()
			return false
		end
		local b = filter(a, removeAll)

		expect(#b).to.equal(0)
	end)
end