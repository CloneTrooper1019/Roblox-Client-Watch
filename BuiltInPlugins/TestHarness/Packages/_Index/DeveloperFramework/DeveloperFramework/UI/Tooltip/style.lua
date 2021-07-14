local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local UIFolderData = require(Framework.UI.UIFolderData)
local DropShadow = require(UIFolderData.DropShadow.style)

if THEME_REFACTOR then
	local dropShadow = DropShadow
	return {
		Padding = 5,
		MaxWidth = 200,
		ShowDelay = 0.3,
		Offset = Vector2.new(10, 5),
		DropShadow = Cryo.Dictionary.join(dropShadow, {
			Radius = 3,
		}),
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local dropShadow = DropShadow(theme, getColor)

		local Default = Style.extend(common.MainText, {
			Padding = 5,
			MaxWidth = 200,
			ShowDelay = 0.3,
			Offset = Vector2.new(10, 5),
			DropShadow = Style.extend(dropShadow.Default, {
				Radius = 3,
			}),
		})

		return {
			Default = Default,
		}
	end
end
