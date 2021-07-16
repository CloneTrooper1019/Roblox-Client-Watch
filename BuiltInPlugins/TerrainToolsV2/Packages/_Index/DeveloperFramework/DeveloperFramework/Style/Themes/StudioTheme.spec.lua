return function()
	local StudioTheme = require(script.Parent.StudioTheme)

	it("should create a base theme without issue", function()
		local result = StudioTheme.mock()
		expect(result).to.be.ok()
	end)
end