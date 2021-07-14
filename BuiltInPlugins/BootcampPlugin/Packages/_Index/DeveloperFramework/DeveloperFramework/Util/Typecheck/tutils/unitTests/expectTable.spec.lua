return function()
	local expectTable = require(script.Parent.expectTable)

	it("should not throw when two tables are equal", function()
		expectTable({a = 1, b = 2, c = 3}).toEqual({a = 1, b = 2, c = 3})
	end)

	it("should throw when two tables are not equal", function()
		expect(function()
			expectTable({a = 1, b = 2}).toEqual({c = 3})
		end).to.throw()
	end)
end