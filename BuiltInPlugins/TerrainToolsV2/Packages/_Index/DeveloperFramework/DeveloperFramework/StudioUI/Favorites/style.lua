local Framework = script.Parent.Parent.Parent

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Style = Util.Style
local StyleModifier = Util.StyleModifier

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local yellow = Color3.fromRGB(246, 183, 2)

if THEME_REFACTOR then

	local filled = {
		Foreground = Decoration.Image,
		ForegroundStyle = {
			Color = yellow,
			Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
		}
	}

	return {
		ElementPadding = UDim.new(0, 5),
		Size = UDim2.new(1, 0, 0, 20),

		Button = {
			Filled = filled,

			Unfilled = {
				Foreground = Decoration.Image,
				ForegroundStyle = {
					Color = yellow,
					Image = "rbxasset://textures/DeveloperFramework/Favorites/star_stroke.png",
				},

				[StyleModifier.Hover] = {
					ForegroundStyle = {
						Color = yellow,
						Image = "rbxasset://textures/StudioToolbox/AssetPreview/star_filled.png",
					},
				},
			}
		},

		Text = Cryo.Dictionary.join(Common.MainText, {
			TextColor = yellow
		})
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local base = {
			Foreground = Decoration.Image,
		}

		local filled = Style.extend(base, {
			ForegroundStyle = {
				Color = yellow,
				Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
			}
		})

		local Default = {
			ElementPadding = UDim.new(0, 5),
			Size = UDim2.new(1, 0, 0, 20),

			Button = {
				Filled = filled,

				Unfilled = Style.extend(base, {
					ForegroundStyle = {
						Color = yellow,
						Image = "rbxasset://textures/DeveloperFramework/Favorites/star_stroke.png",
					},

					[StyleModifier.Hover] = {
						ForegroundStyle = {
							Color = yellow,
							Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
						}
					}
				})
			},

			Text = Style.extend(common.MainText, {
				TextColor = yellow
			})
		}

		return {
			Default = Default
		}
	end
end
