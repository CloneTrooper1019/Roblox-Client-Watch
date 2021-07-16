local Framework = script.Parent.Parent.Parent

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)

local Util = require(Framework.Util)
local deepCopy = Util.deepCopy
local Style = Util.Style

local StyleKey = require(Framework.Style.StyleKey)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	return {
		BackgroundStyle = roundBox,
		BorderColor = StyleKey.Border,
		Width = 240,
		MaxHeight = 240,
		Offset = Vector2.new(0, 0),
		Text = {
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)

		return {
			Default = Style.extend(common.Border, {
				BackgroundStyle = roundBox.Default,
				Width = 240,
				MaxHeight = 240,
				Offset = Vector2.new(0, 0),
				Text = {
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
				},
			})
		}
	end
end
