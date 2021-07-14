local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)
local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local Util = require(Framework.Util)
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Size = UDim2.fromOffset(100, 50),
		Hover = {
			Background = StyleKey.ButtonHover,
		},
		Disabled = {
			Background = StyleKey.ButtonDisabled,
			TextColor = StyleKey.DimmedText,
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.MainText, {
			Size = UDim2.fromOffset(100, 50),
			Background = theme:GetColor("MainBackground"),
			Hover = {
				Color = StyleKey.ButtonHover
			}
		})

		return {
			Default = Default,
		}
	end
end
