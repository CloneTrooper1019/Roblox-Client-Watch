local Framework = script.Parent.Parent.Parent

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local deepCopy = Util.deepCopy

local StyleKey = require(Framework.Style.StyleKey)

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)
local Slider = require(UIFolderData.Slider.style)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	local slider = deepCopy(Slider)
	local function buttonStyle(image)
		return {
			Size = UDim2.fromOffset(28, 28),

			Foreground = Decoration.Image,
			ForegroundStyle = {
				Image = image,
			},

			Background = Decoration.RoundBox,
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				Color = StyleKey.ImageButtonBackground,
			}),

			[StyleModifier.Hover] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Transparency = 0.5,
					Color = StyleKey.ImageButtonHover,
				}),
			},

			[StyleModifier.Disabled] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Color = StyleKey.ButtonDisabled,
					Transparency = 0.5
				}),
			}
		}
	end

	return {
		Scrubber = Cryo.Dictionary.join(slider, {
			UpperKnobBackground = nil,
			UpperKnobBackgroundStyle = {},
			Size = UDim2.new(1, slider.KnobSize.X, 0, 15)
		}),
		Controls = {
			Size = UDim2.new(1, 0, 0, 46),
			Padding = {
				Top = 5,
				Left = 11,
				Bottom = 11,
				Right = 11
			},

			PauseButton = buttonStyle("rbxasset://textures/DeveloperFramework/MediaPlayerControls/pause_button.png"),
			PlayButton = buttonStyle("rbxasset://textures/DeveloperFramework/MediaPlayerControls/play_button.png"),
		}
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)
		local slider = Slider(theme, getColor)

		local function buttonStyle(image)
			return {
				Size = UDim2.fromOffset(28, 28),

				Foreground = Decoration.Image,
				ForegroundStyle = {
					Image = image,
					Color = common.MainText.TextColor,
				},

				Background = Decoration.RoundBox,
				BackgroundStyle = roundBox.Default,

				[StyleModifier.Hover] = {
					BackgroundStyle = Style.extend(roundBox.Default, {
						Transparency = 0.5
					}),
				},

				[StyleModifier.Disabled] = {
					BackgroundStyle = Style.extend(roundBox.Default, {
						Color = Color3.fromRGB(201, 201, 201),
						Transparency = 0.5
					}),
				}
			}
		end

		local Default = {
			Scrubber = Style.extend(slider.Default, {
				UpperKnobBackground = nil,
				UpperKnobBackgroundStyle = {},
				Size = UDim2.new(1, slider.Default.KnobSize.X, 0, 15)
			}),
			Controls = {
				Size = UDim2.new(1, 0, 0, 46),
				Padding = {
					Top = 5,
					Left = 11,
					Bottom = 11,
					Right = 11
				},

				PauseButton = buttonStyle("rbxasset://textures/DeveloperFramework/MediaPlayerControls/pause_button.png"),
				PlayButton = buttonStyle("rbxasset://textures/DeveloperFramework/MediaPlayerControls/play_button.png"),
			}
		}

		return {
			Default = Default
		}
	end
end
