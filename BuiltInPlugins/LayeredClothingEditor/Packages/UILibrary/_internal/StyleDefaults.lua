--[[
	Provides style utility for the UILibrary.
	Default values for style can be defined here.
]]

local Style = {}

--Defines default entries for the Style table in createTheme.
--Default entries are only to provide compatibility, not actual theme info.
Style.Defaults = {
	font = Enum.Font.SourceSans,

	backgroundColor = Color3.new(),
	liveBackgroundColor = Color3.new(),
	textColor = Color3.new(),
	subTextColor = Color3.new(),
	dimmerTextColor = Color3.new(),

	itemColor = Color3.new(),
	borderColor = Color3.new(),

	hoveredItemColor = Color3.new(),
	hoveredTextColor = Color3.new(),

	primaryItemColor = Color3.new(),
	primaryBorderColor = Color3.new(),
	primaryTextColor = Color3.new(),

	primaryHoveredItemColor = Color3.new(),
	primaryHoveredBorderColor = Color3.new(),
	primaryHoveredTextColor = Color3.new(),

	selectionColor = Color3.new(),
	selectionBorderColor = Color3.new(),
	selectedTextColor = Color3.new(),

	shadowColor = Color3.new(),
	shadowTransparency = Color3.new(),

	separationLineColor = Color3.new(),

	disabledColor = Color3.new(),
	errorColor = Color3.new(),

	hoverColor = Color3.new(),

	hyperlinkTextColor = Color3.new(),
}

-- A function that checks to see if there are any missing or
-- extraneous keys in the given style. If a value is available
-- for all necessary entries, then the UILibrary will be able to run.
Style.isValid = function(style)
	local requiredStyle = Style.Defaults

	for key, _ in pairs(requiredStyle) do
		if not style[key] then
			return false
		end
	end

	for key, _ in pairs(style) do
		if not requiredStyle[key] then
			return false
		end
	end

	return true
end

return Style