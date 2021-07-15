return function()
	local Framework = script.Parent.Parent
	local getRawComponentStyle = require(script.Parent.getRawComponentStyle)

	it("should get the style table for the correct UI component", function()
		local result = getRawComponentStyle("Button")

		local styleFile = Framework.UI.Button:FindFirstChild("style")
		local styleTable = require(styleFile)

		expect(styleTable).to.equal(result)
	end)

	it("should get the style table for the correct StudioUI component", function()
		local result = getRawComponentStyle("SearchBar")

		local styleFile = Framework.StudioUI.SearchBar:FindFirstChild("style")
		local styleTable = require(styleFile)

		expect(styleTable).to.equal(result)
	end)
end