local Framework = script.Parent.Parent.Parent

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)
local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	return {
		Padding = 10,
		BackgroundStyle = roundBox,
		[StyleModifier.Hover] = {
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				BorderColor = StyleKey.DialogMainButton,
			}),
		},
		DropdownMenu = {
			BackgroundStyle = roundBox,
			Width = 240,
			MaxHeight = 240,
			Offset = Vector2.new(0, 0),
		},
		Size = UDim2.new(0, 240, 0, 32),
		ArrowOffset = 10,
		ArrowSize = UDim2.new(0, 12, 0, 12),
		ArrowImage = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",
		ArrowColor = StyleKey.MainText,
		PlaceholderTextColor = StyleKey.DimmedText,
		Text = Cryo.Dictionary.join(Common.MainText, {
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)

		return {
			Default = Style.extend(common.Border, {
				Padding = 10,
				BackgroundStyle = roundBox.Default,
				[StyleModifier.Hover] = {
					BackgroundStyle = Style.extend(roundBox.Default, common.BorderHover),
				},
				DropdownMenu = {
					BackgroundStyle = roundBox.Default,
					Width = 240,
					MaxHeight = 240,
					Offset = Vector2.new(0, 0),
				},
				Size = UDim2.new(0, 240, 0, 32),
				ArrowOffset = 10,
				ArrowSize = UDim2.new(0, 12, 0, 12),
				ArrowImage = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",
				ArrowColor = theme:GetColor("MainText"),
				PlaceholderTextColor = theme:GetColor("DimmedText"),
				Text = Style.extend(common.MainText, {
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			})
		}
	end
end
