--[[
	The control panel for Sounds and VideoFrames that provides a
	play/pause button, progress bar, and a time label to show time left.

	Required Props:
		boolean IsPlaying: Whether or not the Sound or VideoFrame is currently playing.
		boolean IsLoaded: Whether or not the Sound or VideoFrame is loaded.
		callback OnPause: Called when clicking the pause button.
		callback OnPlay: Called when first clicking the play button.
		boolean ShowTreeView: used to control the position of the play/pause button.
		number TimeLength: The total Sound/VideoFrame length.
		number TimePassed: How much time has passed since playing the Sound/VideoFrame.

	Optional Props:
		Vector2 AnchorPoint: The AnchorPoint of the component
		UDim2 LayoutOrder: The LayoutOrder of the component
		UDim2 Position: The Position of the component
]]
local FFlagHideOneChildTreeviewButton = game:GetFastFlag("HideOneChildTreeviewButton")

local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local getTimeString = require(Library.Utils.getTimeString)
local RoundButton = require(Library.Components.RoundFrame)

local LoadingIndicator = require(Library.Components.LoadingIndicator)

local TIME_LABEL_HEIGHT = 15
local BUTTON_SIZE = 28
local AUDIO_CONTROL_HEIGHT = 35
local AUDIO_CONTROL_WIDTH_OFFSET_WITH_TREE = 50
local AUDIO_CONTROL_WIDTH_OFFSET_NO_TREE = 70

if FFlagHideOneChildTreeviewButton then
	AUDIO_CONTROL_WIDTH_OFFSET_NO_TREE = 10
end

local MediaControl = Roact.PureComponent:extend("MediaControl")

MediaControl.defaultProps = {
	TimePassed = 0,
}

function MediaControl:init()
	self.onActivated = function()
		if not self.props.IsLoaded then
			return
		end

		if self.props.IsPlaying then
			self.props.OnPause()
		else
			self.props.OnPlay()
		end
	end
end

function MediaControl:render()
	return withTheme(function(theme)
		local audioPreviewTheme = theme.assetPreview.audioPreview
		local props = self.props

		local anchorPoint = props.AnchorPoint
		local layoutOrder = props.LayoutOrder
		local isLoaded = props.IsLoaded
		local isPlaying = props.IsPlaying
		local position = props.Position
		local showTreeView = props.ShowTreeView
		local timeLength = props.TimeLength
		local timePassed = props.TimePassed

		local controlOffset = showTreeView and AUDIO_CONTROL_WIDTH_OFFSET_WITH_TREE or AUDIO_CONTROL_WIDTH_OFFSET_NO_TREE
		local timeString = getTimeString(timePassed) .. '/' .. getTimeString(timeLength)

		return Roact.createElement("Frame", {
			AnchorPoint = anchorPoint,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Position = position,
			Size = UDim2.new(1, 0, 0, AUDIO_CONTROL_HEIGHT),
		}, {
			Button = Roact.createElement(RoundButton, {
				AnchorPoint = Vector2.new(0.5, 0),
				AutoButtonColor = false,
				BackgroundColor3 = isLoaded and audioPreviewTheme.buttonBackgroundColor or audioPreviewTheme.buttonDisabledBackgroundColor,
				BackgroundTransparency = isLoaded and 0 or audioPreviewTheme.buttonDisabledBackgroundTransparency,
				BorderSizePixel = 0,
				OnActivated = self.onActivated,
				Position = UDim2.new(0, 24, 0, 0),
				Size = UDim2.new(0, BUTTON_SIZE, 0, BUTTON_SIZE),
			}, {
				PlayOrPauseIcon = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = isPlaying and audioPreviewTheme.pauseButton or audioPreviewTheme.playButton,
					ImageColor3 = audioPreviewTheme.buttonColor,
					ImageTransparency = isLoaded and 0 or audioPreviewTheme.buttonDisabledBackgroundTransparency,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 1, 0),
				}),
			}),

			TimeComponent = isLoaded and Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Font = audioPreviewTheme.font,
				Position = UDim2.new(1, -controlOffset, 0.5, 0),
				Size = UDim2.new(0, 204, 0, TIME_LABEL_HEIGHT),
				Text = timeString,
				TextColor3 = audioPreviewTheme.textColor,
				TextSize = audioPreviewTheme.fontSize,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),

			LoadingIndicator = (not isLoaded) and Roact.createElement(LoadingIndicator, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -controlOffset, 0.5, 0),
				Size = UDim2.new(0, 50, 0, TIME_LABEL_HEIGHT),
			}),
		})
	end)
end

return MediaControl