local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Util = require(Framework.Util)
local deepCopy = Util.deepCopy
local Cryo = Util.Cryo
local Style = Util.Style

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local UIFolderData = require(Framework.UI.UIFolderData)
local RoundBox = require(UIFolderData.RoundBox.style)
local Button = require(UIFolderData.Button.style)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local common = deepCopy(Common)
	local roundBox = deepCopy(RoundBox)
	local button = deepCopy(Button)

	local infoRowText = common.MainText

	return {
		BackgroundColor = StyleKey.MainBackground,
		BackgroundStyle = roundBox,

		CloseButton = {
			Position = UDim2.new(1, 0, 0, 0),
			AnchorPoint = Vector2.new(0, 1),

			Image = "rbxasset://textures/DeveloperFramework/AssetPreview/close_button.png",
			Size = UDim2.fromOffset(28, 28),
		},

		ScrollingFrame = {
			ElementPadding = 10,
			Padding = {
				PaddingTop = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 25),
				PaddingLeft = UDim.new(0, 10),
			},
			AssetName = Cryo.Dictionary.join(common.MainText, {
				Font = Enum.Font.SourceSansBold,
				TextSize = 24,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			AssetDescription = Cryo.Dictionary.join(common.MainText, {
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			InfoRow = {
				Text = infoRowText,
				LeftText = Cryo.Dictionary.join(common.MainText, {
					TextTransparency = 0.5,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				RightText = Cryo.Dictionary.join(common.MainText, {
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),
			}
		},

		-- The background of this needs to extend to the edges of the parent, so we
		-- override the padding on the ScrollingFrame here with negative margins.
		AssetRenderMargin = {
			Top = 0,
			Right = -10,
			Bottom = 0,
			Left = -10,
		},

		ButtonArea = {
			ElementPadding = UDim.new(0, 10),
			Padding = {
				PaddingTop = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 15),
				PaddingLeft = UDim.new(0, 12),
			},
			Size = UDim2.new(1, 0, 0, 52),

			Context = {
				Size = UDim2.fromOffset(28, 28),
				Background = Decoration.Box,
				BackgroundStyle = {
					Color = StyleKey.ImageButtonBackground,
					Transparency = 0
				},

				Foreground = Decoration.Image,
				ForegroundStyle = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = "rbxasset://textures/DeveloperFramework/AssetPreview/more.png",
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.6, 0, 0.6, 0),
					ScaleType = Enum.ScaleType.Stretch
				},
			},

			Action = "RoundPrimary",
			ActionBuy = Cryo.Dictionary.join(button["&RoundPrimary"], {
				Foreground = Decoration.Image,
				ForegroundStyle = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = "rbxasset://textures/ui/common/robux_small.png",
					Position = UDim2.new(0.05, 0, 0.5, 0),
					Size = UDim2.new(0, 16, 0.6, 0),
					ScaleType = Enum.ScaleType.Fit,
				},
				TextSize = common.MainText.TextSize,
			})
		},
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local roundBox = RoundBox(theme, getColor)
		local button = Button(theme, getColor)

		local infoRowText = common.MainText

		local Default = Style.extend(common.MainText, common.Border, {
			BackgroundColor = common.Background.Color,
			BackgroundStyle = roundBox.Default,

			CloseButton = {
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(0, 1),

				Image = "rbxasset://textures/DeveloperFramework/AssetPreview/close_button.png",
				Size = UDim2.fromOffset(28, 28),
			},

			ScrollingFrame = {
				ElementPadding = 10,
				Padding = {
					PaddingTop = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 25),
					PaddingLeft = UDim.new(0, 10),
				},
				AssetName = Style.extend(common.MainText, {
					Font = Enum.Font.SourceSansBold,
					TextSize = 24,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				AssetDescription = Style.extend(common.MainText, {
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				InfoRow = {
					Text = infoRowText,
					LeftText = Style.extend(infoRowText, {
						TextTransparency = 0.5,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					RightText = Style.extend(infoRowText, {
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}
			},

			-- The background of this needs to extend to the edges of the parent, so we
			-- override the padding on the ScrollingFrame here with negative margins.
			AssetRenderMargin = {
				Top = 0,
				Right = -10,
				Bottom = 0,
				Left = -10,
			},

			ButtonArea = {
				ElementPadding = UDim.new(0, 10),
				Padding = {
					PaddingTop = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 15),
					PaddingLeft = UDim.new(0, 12),
				},
				Size = UDim2.new(1, 0, 0, 52),

				Context = {
					Size = UDim2.fromOffset(28, 28),
					Background = Decoration.Box,
					BackgroundStyle = {
						Color = common.Border.BorderColor,
						Transparency = 0
					},

					Foreground = Decoration.Image,
					ForegroundStyle = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = "rbxasset://textures/DeveloperFramework/AssetPreview/more.png",
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.6, 0, 0.6, 0),
						ScaleType = Enum.ScaleType.Stretch
					},
				},

				Action = "RoundPrimary",
				ActionBuy = Style.extend(button.RoundPrimary, {
					Foreground = Decoration.Image,
					ForegroundStyle = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = "rbxasset://textures/ui/common/robux_small.png",
						Position = UDim2.new(0.05, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0.6, 0),
						ScaleType = Enum.ScaleType.Fit
					},
				})
			},
		})

		return {
			Default = Default
		}
	end
end
