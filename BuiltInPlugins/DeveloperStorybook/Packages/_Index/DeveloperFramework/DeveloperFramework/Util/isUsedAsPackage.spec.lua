return function()
	local isUsedAsPackage = require(script.Parent.isUsedAsPackage)

	-- This is mainly to avoid CheckModules complaining
	it("should be a function", function()
		expect(type(isUsedAsPackage) == "function").to.be.ok()
	end)
end