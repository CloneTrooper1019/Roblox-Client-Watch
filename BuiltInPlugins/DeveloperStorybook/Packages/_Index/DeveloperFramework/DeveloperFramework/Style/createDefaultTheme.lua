--[[
	Creates a default theme with given props.
]]

local Style = script.Parent

local BaseTheme = require(Style.Themes.BaseTheme)
local Stylizer = require(Style.Stylizer)

return function(themeProps)
	assert(typeof(themeProps) == "table", "createDefaultTheme expects themeProps parameter to be a table")
	assert(typeof(themeProps.themesList) == "table", "createDefaultTheme expects themeProps to contain a table `themesList`")
	assert(typeof(themeProps.getThemeName) == "function", "createDefaultTheme expects themeProps to contain a function `getThemeName`")

	local style = Stylizer.new(themeProps.themesList[themeProps.getThemeName()], themeProps)
	return style:extend(BaseTheme)
end