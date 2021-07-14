--[[
	A set of constants that will be used to theme a component.
	A Style under the hood is little more than a table with an join function.

	Example:
		local MainText = Style.new({
			Font = Enum.Font.SourceSans,
			Color = getColor("MainText"),
			TextSize = 16,
		})

	Style.extend lets you merge any number of Styles to create a new Style.
	This allows you to create base Styles that other Styles use.
	Example:
		local Bold = Style.new({
			Font = Enum.Font.SourceSansBold,
		})

		local BoldTextLabel = Style.extend(MainText, Bold, {
			BackgroundColor = getColor("Background"),
		})
]]

local Framework = script.Parent.Parent
local Immutable = require(Framework.Util.Immutable)

local Style = {}
function Style.new(values)
	assert(values, "Style.new expects a table of values.")
	return values
end

function Style.extend(...)
	return Immutable.JoinDictionaries(...)
end

return Style
