return function()
	local filterMap = require(script.Parent.filterMap)

	it("should return a new table", function()
		local a = {1, 2, 3}
		local function callback()
			return 1
		end
		local b = filterMap(a, callback)

		expect(b).never.to.equal(a)
	end)

	it("should call the callback for each element", function()
		local a = {
			"foo1",
			"foo2",
			"foo3"
		}
		local copy = {}
		local function callback(value, index)
			copy[index] = value
			return value
		end
		filterMap(a, callback)

		for key, value in pairs(a) do
			expect(copy[key]).to.equal(value)
		end

		for key, value in pairs(copy) do
			expect(value).to.equal(a[key])
		end
	end)

	it("should correctly use the filter callback", function()
		local a = {1, 2, 3, 4, 5}
		local function doubleOddOnly(value)
			if value % 2 == 0 then
				return nil
			else
				return value * 2
			end
		end
		local b = filterMap(a, doubleOddOnly)

		expect(#b).to.equal(3)
		expect(b[1]).to.equal(2)
		expect(b[2]).to.equal(6)
		expect(b[3]).to.equal(10)
	end)

	it("should copy the list correctly", function()
		local a = {1, 2, 3}
		local function copyCallback(value)
			return value
		end
		local b = filterMap(a, copyCallback)

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
		local a = filterMap({}, callback)

		expect(#a).to.equal(0)
		expect(called).to.equal(false)
	end)

	it("should remove all elements from a list when callback return always nil", function()
		local a = {6, 2, 8, 6, 7}
		local function removeAll()
			return nil
		end
		local b = filterMap(a, removeAll)

		expect(#b).to.equal(0)
	end)
end