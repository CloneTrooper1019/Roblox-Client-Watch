local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local UIFolderData = require(Framework.UI.UIFolderData)
local Box = require(UIFolderData.Box.style)
local RoundBox = require(UIFolderData.RoundBox.style)

local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local StatelessAudioPlayer = require(StudioUIFolderData.StatelessAudioPlayer.style)
local StatelessVideoPlayer = require(StudioUIFolderData.StatelessVideoPlayer.style)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

--[[
	Reduce the width of the controls so that the TreeView button has space to display on the right
]]
local function shrinkMediaPlayerControlsWidth(mediaPlayerStyle)
	local mediaPlayerStyleClone = deepCopy(mediaPlayerStyle)

	mediaPlayerStyleClone.MediaPlayerControls.Controls.Size =
		mediaPlayerStyleClone.MediaPlayerControls.Controls.Size - UDim2.new(0, 32, 0, 0)

	return mediaPlayerStyleClone
end

local DEFAULT_HEIGHT = 242

if THEME_REFACTOR then
	local box = deepCopy(Box)
	local roundBox = deepCopy(RoundBox)
	local audioPlayerStyle = deepCopy(StatelessAudioPlayer)
	local videoPlayerStyle = deepCopy(StatelessVideoPlayer)

	local treeViewButtonBackgroundStyle = Cryo.Dictionary.join(roundBox, {
		Color = StyleKey.ImageButtonBackground,
		Transparency = 0
	})

	return {
		Background = Decoration.Box,
		BackgroundStyle = Cryo.Dictionary.join(box, {
			Color = StyleKey.SubBackground,
		}),

		RenderView = {
			Size = UDim2.new(1, 0, 0, DEFAULT_HEIGHT),

			TreeViewButton = {
				Size = UDim2.fromOffset(28, 28),
				Background = Decoration.RoundBox,
				BackgroundStyle = treeViewButtonBackgroundStyle,

				[StyleModifier.Hover] = {
					BackgroundStyle = Cryo.Dictionary.join(treeViewButtonBackgroundStyle, {
						Transparency = 0.3
					}),
				},

				Foreground = Decoration.Image,
				ForegroundStyle = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = "rbxasset://textures/DeveloperFramework/AssetRender/hierarchy.png",
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					ScaleType = Enum.ScaleType.Stretch
				},

			}
		},
		TreeView = {
			Size = UDim2.new(1, 0, 0, 120),
			HorizontalSize = UDim2.new(0.4, 0, 0, DEFAULT_HEIGHT),
		},

		AudioPlayer = audioPlayerStyle,
		AudioPlayerWithTreeViewButton = shrinkMediaPlayerControlsWidth(audioPlayerStyle),

		VideoPlayer = videoPlayerStyle,
		VideoPlayerWithTreeViewButton = shrinkMediaPlayerControlsWidth(videoPlayerStyle),
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local box = Box(theme, getColor)
		local roundBox = RoundBox(theme, getColor)

		local audioPlayerStyle = StatelessAudioPlayer(theme, getColor).Default
		local videoPlayerStyle = StatelessVideoPlayer(theme, getColor).Default

		local treeViewButtonBackgroundStyle = Style.extend(roundBox.Default, {
			Color = common.Border.BorderColor,
			Transparency = 0
		})

		local Default = Style.new({
			Background = Decoration.Box,
			BackgroundStyle = Style.extend(box.Default, {
				Color = common.Background.Color,
			}),

			RenderView = {
				Size = UDim2.new(1, 0, 0, DEFAULT_HEIGHT),

				TreeViewButton = {
					Size = UDim2.fromOffset(28, 28),
					Background = Decoration.RoundBox,
					BackgroundStyle = treeViewButtonBackgroundStyle,

					[StyleModifier.Hover] = {
						BackgroundStyle = Style.extend(treeViewButtonBackgroundStyle, {
							Transparency = 0.3
						}),
					},

					Foreground = Decoration.Image,
					ForegroundStyle = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = "rbxasset://textures/DeveloperFramework/AssetRender/hierarchy.png",
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.fromOffset(16, 16),
						ScaleType = Enum.ScaleType.Stretch
					},

				}
			},
			TreeView = {
				Size = UDim2.new(1, 0, 0, 120),
				HorizontalSize = UDim2.new(0.4, 0, 0, DEFAULT_HEIGHT),
			},

			AudioPlayer = audioPlayerStyle,
			AudioPlayerWithTreeViewButton = shrinkMediaPlayerControlsWidth(audioPlayerStyle),

			VideoPlayer = videoPlayerStyle,
			VideoPlayerWithTreeViewButton = shrinkMediaPlayerControlsWidth(videoPlayerStyle),
		})

		return {
			Default = Default
		}
	end
end
