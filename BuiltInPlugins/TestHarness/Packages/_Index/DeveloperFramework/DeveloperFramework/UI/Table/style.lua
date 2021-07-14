local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local StyleKey = require(Framework.Style.StyleKey)

if THEME_REFACTOR then
	return {
		Border = StyleKey.Border,
		ScrollHeaderPadding = {
			Right = 8,
		},
		RowHeight = 24,
		HeaderCellPadding = 5,
		HeaderHeight = 32,
		FooterHeight = 36,
		IconColor = StyleKey.Icon,
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		return {
			Default = common.MainText,
		}
	end
end
