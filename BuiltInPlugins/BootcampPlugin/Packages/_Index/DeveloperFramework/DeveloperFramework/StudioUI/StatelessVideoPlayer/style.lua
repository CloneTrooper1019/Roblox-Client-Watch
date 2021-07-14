local Framework = script.Parent.Parent.Parent

local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local MediaPlayerControls = require(StudioUIFolderData.MediaPlayerControls.style)

local UI = require(Framework.UI)
local Box = UI.Decoration.Box

local Util = require(Framework.Util)
local deepCopy = Util.deepCopy
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		PlayVideoIcon = {
			Size = UDim2.fromOffset(30, 30),
			ScaleType = Enum.ScaleType.Fit,
			Image = deepCopy(MediaPlayerControls).Controls.PlayButton.ForegroundStyle.Image,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		},
		PausedOverlay = {
			Background = Box,
			BackgroundStyle = {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0.5,
			},
		},
		MediaPlayerControls = deepCopy(MediaPlayerControls)
	}
else
	return function(theme, getColor)
		local mediaPlayerControls = MediaPlayerControls(theme, getColor)

		local controlsStyle = mediaPlayerControls.Default

		local Default = {
			PlayVideoIcon = {
				Size = UDim2.fromOffset(30, 30),
				ScaleType = Enum.ScaleType.Fit,
				Image = controlsStyle.Controls.PlayButton.ForegroundStyle.Image,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			},
			PausedOverlay = {
				Background = Box,
				BackgroundStyle = {
					Color = Color3.fromRGB(0, 0, 0),
					Transparency = 0.5,
				},
			},
			MediaPlayerControls = controlsStyle
		}

		return {
			Default = Default
		}
	end
end
