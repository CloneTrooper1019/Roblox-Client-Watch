local Framework = script.Parent.Parent.Parent

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style
local StyleModifier = Util.StyleModifier

local StyleKey = require(Framework.Style.StyleKey)

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)

local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local Votes = require(StudioUIFolderData.Votes.style)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local red = Color3.fromRGB(0, 100, 0)
local green = Color3.fromRGB(100, 0, 0)

if THEME_REFACTOR then
	local roundBox = deepCopy(RoundBox)
	local common = deepCopy(Common)
	local votes = deepCopy(Votes)

	local function buttonStyle(image, selectedColor)
		local base = {
			Size = UDim2.fromOffset(28, 28),
			Foreground = Decoration.Image,
			ForegroundStyle = {
				Image = image,
			},
			Background = Decoration.RoundBox,
			BackgroundStyle = Cryo.Dictionary.join(roundBox, {
				Color = StyleKey.ButtonDisabled,
			}),

			[StyleModifier.Selected] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Color = selectedColor,
				}),
			}
		}

		return Cryo.Dictionary.join(base, {
			CanVote = Cryo.Dictionary.join(base, {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Color = StyleKey.ImageButtonBackground,
				}),
				[StyleModifier.Hover] = {
					BackgroundStyle = Cryo.Dictionary.join(roundBox, {
						Color = StyleKey.ImageButtonHover,
					}),
				}
			})
		})
	end

	return {
		Background = Decoration.RoundBox,
		BackgroundStyle = Cryo.Dictionary.join(roundBox, {
			Color = StyleKey.SubBackground,
			BorderTransparency = 1
		}),
		Padding = {
			Top = 0,
			Right = 10,
			Left = 10,
			Bottom = 0
		},
		Size = UDim2.new(1, 0, 0, 36),

		Buttons = {
			VoteUp = buttonStyle("rbxasset://textures/StudioToolbox/AssetPreview/vote_up.png", red),
			VoteDown = buttonStyle("rbxasset://textures/StudioToolbox/AssetPreview/vote_down.png", green),
		},

		VoteCount = Cryo.Dictionary.join(common.MainText, {
			TextSize = 14
		}),

		Votes = Cryo.Dictionary.join(votes, {
			Text = Cryo.Dictionary.join(votes.Text, {
				TextSize = common.MainText.TextSize,
			})
		}),
	}
else
	return function(theme, getColor)
		local textColor = Color3.fromRGB(170, 170, 170)

		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)
		local votes = Votes(theme, getColor)

		local function buttonStyle(image, selectedColor)

			local base = {
				Size = UDim2.fromOffset(28, 28),
				Foreground = Decoration.Image,
				ForegroundStyle = {
					Image = image,
				},
				Background = Decoration.RoundBox,
				BackgroundStyle = Style.extend(roundBox.Default, {
					Color = Color3.fromRGB(10, 10, 10)
				}),

				[StyleModifier.Selected] = {
					BackgroundStyle = Style.extend(roundBox.Default, {
						Color = selectedColor,
					}),
				}
			}

			return Style.extend(base, {
				CanVote = Style.extend(base, {
					BackgroundStyle = Style.extend(roundBox.Default, {
						Color = Color3.fromRGB(178, 178, 178),
					}),
					[StyleModifier.Hover] = {
						BackgroundStyle = Style.extend(roundBox.Default, {
							Color = Color3.fromRGB(201, 201, 201),
						}),
					}
				})
			})
		end

		local Default = {
			Background = Decoration.RoundBox,
			BackgroundStyle = Style.extend(roundBox.Default, {
				Color = common.Background.Color,
				BorderTransparency = 1
			}),
			Padding = {
				Top = 0,
				Right = 10,
				Left = 10,
				Bottom = 0
			},
			Size = UDim2.new(1, 0, 0, 36),

			Buttons = {
				VoteUp = buttonStyle("rbxasset://textures/StudioToolbox/AssetPreview/vote_up.png", red),
				VoteDown = buttonStyle("rbxasset://textures/StudioToolbox/AssetPreview/vote_down.png", green),
			},

			VoteCount = Style.extend(common.MainText, {
				TextColor = textColor,
				TextSize = 14
			}),

			Votes = Style.extend(votes.Default, {
				Text = Style.extend(votes.Default.Text, {
					TextColor = textColor,
					TextSize = common.MainText.TextSize,
				})
			}),
		}

		return {
			Default = Default
		}
	end
end
