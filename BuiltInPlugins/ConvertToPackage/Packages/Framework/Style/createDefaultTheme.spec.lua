return function()
	local createDefaultTheme = require(script.Parent.createDefaultTheme)
	local DarkTheme =  require(script.Parent.Themes.DarkTheme)

	local function callWithProps()
		local themeProps = {
			getThemeName = function() return "Dark" end,
			themesList = {
				Dark = DarkTheme,
			},
		}

		return createDefaultTheme(themeProps)
	end

	it("should create a base theme without issue", function()
		local result = callWithProps()
		expect(result).to.be.ok()
	end)

	it("should be extendable", function()
		local result = callWithProps()
		local success, _ = pcall(function()
			return result:extend({
				hello = "world",
			})
		end)
		expect(success).to.equal(true)
	end)
end