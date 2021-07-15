--[[
	A collection of color values shared between engineering
	and design for coloring Studio widgets based on theme.

	This palette is used for the getColor function when constructing a Theme.
	getColor can be called with the string name of a color.
	Example:
		return Theme.new(function(theme, getColor)
			-- 'color' will equal a white Color3 if Studio is currently Light theme,
			-- and a black Color3 if Studio is currently on Dark theme.
			return {
				color = getColor("Mock_TestColor"),
			}
		end)

	This file should contain ONLY colors.
	Other values that may change between theme (font, etc) go elsewhere.
	See StyleValue for a way to create items like this outside of Palette.
]]

local StyleValue = require(script.Parent.StyleValue)

-- Define colors
local White = Color3.new(1, 1, 1)
local Black = Color3.new(0, 0, 0)

-- Define palette
local Palette = {
	Mock_TestColor = StyleValue.new("Mock_TestColor", {
		Light = White,
		Dark = Black,
	}),

	--TODO: Populate table with palette colors here after syncing with Design
}

return Palette
