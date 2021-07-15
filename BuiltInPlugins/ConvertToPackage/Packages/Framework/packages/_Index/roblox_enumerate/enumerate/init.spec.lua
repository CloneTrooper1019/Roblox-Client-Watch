return function()
	local enumerate = require(script.Parent)

	it("should load a function", function()
		expect(typeof(enumerate)).to.equal("function")
	end)
end