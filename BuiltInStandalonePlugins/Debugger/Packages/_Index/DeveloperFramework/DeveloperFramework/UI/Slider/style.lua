local Framework = script.Parent.Parent.Parent

local UIFolderData = require(Framework.UI.UIFolderData)
local RangeSlider = require(UIFolderData.RangeSlider.style)

local Util = require(Framework.Util)
local deepCopy = Util.deepCopy
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return deepCopy(RangeSlider)
else
	return function(theme, getColor)
		return RangeSlider(theme, getColor)
	end
end
