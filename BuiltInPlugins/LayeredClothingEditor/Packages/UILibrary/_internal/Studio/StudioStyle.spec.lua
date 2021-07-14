local StudioStyle = require(script.Parent.StudioStyle)

local Library = script.Parent.Parent
local Style = require(Library.StyleDefaults)
local StudioTheme = require(Library.Studio.StudioTheme)

return function()
	it("should define all of the keys in the Style.Defaults object", function()
		local numKeysFound = 0
		local numKeysExpected = 0

		local defaultStyle = Style.Defaults
		local studioTheme = StudioTheme.newDummyTheme(function() return {} end)
		local mockStudioTheme = studioTheme.getTheme()
		local studioStyle = StudioStyle.new(mockStudioTheme.GetColor,
			Enum.StudioStyleGuideColor,
			Enum.StudioStyleGuideModifier)

		-- every key in the default style should be accounted for
		for colorKey, _ in pairs(defaultStyle) do
			numKeysExpected = numKeysExpected + 1
			expect(studioStyle[colorKey]).to.be.ok()
		end

		-- there should not be extra keys defined
		for _, _ in pairs(studioStyle) do
			numKeysFound = numKeysFound + 1
		end

		expect(numKeysFound).to.equal(numKeysExpected)

		-- clean up
		studioTheme:destroy()
	end)
end