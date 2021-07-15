--[[
	Represents a value which can change based on the current theme.
	A StyleValue is a mapping from theme names to values.
	For example, colors can be StyleValues.
		Background = StyleValue.new("Background", {
			Light = Color3.new(1, 1, 1),
			Dark = Color3.new(0, 0, 0),
		}),

	StyleValue.new(name, themesToValuesMap): Constructs a new StyleValue.
		string name: The name of the StyleValue.
		map themesToValuesMap: A map from theme names to the constant
			values that this StyleValue returns at those themes.

	StyleValue:get(theme): Gets the value at the current theme name.
	Example:
		local text = StyleValue.new("Text", {
			Light = "This is Light theme!",
			Dark = "This is Dark theme!",
		})

		return Theme.new(function(theme, getColor)
			-- 'whatThemeIsIt' will equal "This is Light theme!" if Studio is currently Light theme,
			-- and "This is Dark theme!" if Studio is currently on Dark theme.
			return {
				whatThemeIsIt = text:get(theme.Name),
			}
		end)
]]

local StyleValue = {}
StyleValue.__index = StyleValue

function StyleValue.new(name, themesToValuesMap)
	assert(name, "StyleValue.new expects a 'name' parameter")
	assert(themesToValuesMap, "StyleValue.new expects a 'themesToValuesMap' parameter")

	local self = {
		name = name,
		themes = themesToValuesMap,
	}

	self.__tostring = function()
		return self.name
	end

	setmetatable(self, StyleValue)
	return self
end

function StyleValue:get(theme)
	return self.themes[theme]
end

return StyleValue
