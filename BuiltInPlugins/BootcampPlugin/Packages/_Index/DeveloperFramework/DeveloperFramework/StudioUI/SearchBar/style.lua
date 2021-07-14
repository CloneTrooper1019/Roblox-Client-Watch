local Framework = script.Parent.Parent.Parent

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local StyleKey = require(Framework.Style.StyleKey)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)

local function buttonStyle(image, hoverImage, theme)
	local hoverStyle

	if THEME_REFACTOR then
		hoverStyle = StyleKey.DialogMainButton
	else
		hoverStyle = theme:GetColor("DialogMainButton")
	end

	local foregroundStyle = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Color = Color3.fromRGB(184, 184, 184),
		Image = image,
		Size = UDim2.new(0.6, 0, 0.6, 0),
		ScaleType = Enum.ScaleType.Fit
	}

	local style = {
		Foreground = Decoration.Image,
		ForegroundStyle = foregroundStyle,
		[StyleModifier.Hover] = {
			ForegroundStyle = Cryo.Dictionary.join(foregroundStyle, {
				Image = hoverImage,
				Color = hoverStyle
			}),
		},
	}

	if THEME_REFACTOR then
		return style
	else
		return Style.new(style)
	end
end

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	return {
		BackgroundColor = StyleKey.MainBackground,
		BackgroundStyle = roundBox,
		Padding = {
			Top = 3,
			Left = 10,
			Bottom = 3,
			Right = 10
		},

		SearchIcon = "rbxasset://textures/StudioSharedUI/search.png",
		IconColor = Color3.fromRGB(184, 184, 184),
		IconWidth = 12,
		IconOffset = 5,

		[StyleModifier.Hover] = {
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				BorderColor = StyleKey.DialogMainButton,
			})
		},

		Hover = {
			BorderColor = StyleKey.DialogMainButton,
		},

		Buttons = {
			Clear = buttonStyle("rbxasset://textures/StudioSharedUI/clear.png", "rbxasset://textures/StudioSharedUI/clear-hover.png"),
			Search = buttonStyle("rbxasset://textures/StudioSharedUI/search.png"),
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)

		local Default = Style.extend(common.MainText, common.Border, {
			BackgroundColor = common.Background.Color,
			BackgroundStyle = roundBox.Default,
			Padding = {
				Top = 3,
				Left = 10,
				Bottom = 3,
				Right = 10
			},

			SearchIcon = "rbxasset://textures/StudioSharedUI/search.png",
			IconColor = Color3.fromRGB(184, 184, 184),
			IconWidth = 14,
			IconOffset = 5,

			[StyleModifier.Hover] = {
				BackgroundStyle = Style.extend(roundBox.Default, common.BorderHover),
			},
			Buttons = {
				Clear = buttonStyle("rbxasset://textures/StudioSharedUI/clear.png", "rbxasset://textures/StudioSharedUI/clear-hover.png", theme),
				Search = buttonStyle("rbxasset://textures/StudioSharedUI/search.png", nil, theme),
			},
		})

		return {
			Default = Default,
		}
	end
end
