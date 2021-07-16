return function()

	local Util = script.Parent
	local THEME_REFACTOR = require(Util.RefactorFlags).THEME_REFACTOR

	if THEME_REFACTOR then
		return
	end

	local Palette = require(Util.Palette)

	it("should be a table of color StyleValues", function()
		expect(Palette).to.be.ok()
		expect(type(Palette)).to.equal("table")
	end)

	it("should have an entry for every color for every theme", function()
		for _, color in pairs(Palette) do
			for _, theme in ipairs(settings().Studio:GetAvailableThemes()) do
				expect(color:get(theme.Name)).to.be.ok()
			end
		end
	end)

	it("should only contain colors", function()
		for _, color in pairs(Palette) do
			for _, theme in ipairs(settings().Studio:GetAvailableThemes()) do
				expect(typeof(color:get(theme.Name))).to.equal("Color3")
			end
		end
	end)
	
end
