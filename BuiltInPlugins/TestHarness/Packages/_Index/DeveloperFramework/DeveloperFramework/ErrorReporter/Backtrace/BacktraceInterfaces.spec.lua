return function()
	local BacktraceInterfaces = require(script.Parent.BacktraceInterfaces)

	it("should return a table", function()
		expect(type(BacktraceInterfaces)).to.equal("table")
	end)
end