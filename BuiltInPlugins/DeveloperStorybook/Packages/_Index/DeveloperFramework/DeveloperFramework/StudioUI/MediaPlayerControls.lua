--[[
	Controls UI for media (audio or video) that comprises a play/pause button, time bar, and a time label.

	Required Props:
		boolean IsPlaying: Whether or not the media is currently playing.
		boolean IsLoaded: Whether or not the media is loaded.
		callback OnPause: Called when clicking the pause button.
		callback OnPlay: Called when clicking the play button.
		number TimeLength: The length of the media (seconds).
		number CurrentTime: How much time has elapsed (seconds).

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Style Style: The style with which to render this component.
		callback OnScrub: Called when scrubbing through the media by clicking or dragging the time bar.
			If this is not defined, scrubbing will be disabled.
			OnScrub(durationSeconds: number)
		Vector2 AnchorPoint: The AnchorPoint of the component
		number LayoutOrder: The LayoutOrder of the component
		UDim2 Position: The Position of the component
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local Typecheck = Util.Typecheck
local formatDuration = Util.formatDuration

local UI = require(Framework.UI)
local Button = UI.Button
local Container = UI.Container
local HoverArea = UI.HoverArea
local LoadingIndicator = UI.LoadingIndicator
local Slider = UI.Slider
local TextLabel = UI.Decoration.TextLabel

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local MediaPlayerControls = Roact.PureComponent:extend("MediaPlayerControls")
Typecheck.wrap(MediaPlayerControls, script)

local noop = function() end

function MediaPlayerControls:init()
	self.onClickPlayPause = function()
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

function MediaPlayerControls.calculateSize(mediaPlayerControlsStyle)
	local scrubberSize = mediaPlayerControlsStyle.Scrubber.Size
	local controlsSize = mediaPlayerControlsStyle.Controls.Size

	return UDim2.new(UDim.new(1, 0), scrubberSize.Y + controlsSize.Y)
end

function MediaPlayerControls:render()
	local props = self.props

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local anchorPoint = props.AnchorPoint
	local layoutOrder = props.LayoutOrder
	local isLoaded = props.IsLoaded
	local isPlaying = props.IsPlaying
	local position = props.Position
	local timeLength = props.TimeLength
	local currentTime = props.CurrentTime
	local onScrub = props.OnScrub
	local disableScrubbing = not onScrub

	local buttonStyle = isPlaying and style.Controls.PauseButton or style.Controls.PlayButton

	return Roact.createElement(Container, {
		AnchorPoint = anchorPoint,
		LayoutOrder = layoutOrder,
		Position = position,
		Size = MediaPlayerControls.calculateSize(style),
	}, {
		Scrubber = Roact.createElement(Slider, {
			Style = style.Scrubber,
			Min = 0,
			Max = timeLength,
			Value = math.clamp(currentTime, 0, timeLength),
			OnValueChanged = disableScrubbing and noop or onScrub,
			Disabled = not isLoaded or disableScrubbing,
		}),

		Controls = Roact.createElement(Container, {
			Position = UDim2.new(UDim.new(0, 0), style.Scrubber.Size.Y),
			Size = style.Controls.Size,
			Padding = style.Controls.Padding,
		}, {
			PlayOrPauseButton = Roact.createElement(Button, {
				OnClick = self.onClickPlayPause,
				Style = buttonStyle,
				StyleModifier = not isLoaded and StyleModifier.Disabled or nil,
			}, {
				HoverArea = isLoaded and Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
			}),

			TimeLabel = isLoaded and Roact.createElement(TextLabel, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(UDim.new(1, 0) - buttonStyle.Size.X, UDim.new(1, 0)),
				Text = formatDuration(currentTime) .. '/' .. formatDuration(timeLength),
				TextXAlignment = Enum.TextXAlignment.Right,
			}),

			LoadingIndicator = (not isLoaded) and Roact.createElement(LoadingIndicator, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 50, 1, 0),
			}),
		}),
	})
end

ContextServices.mapToProps(MediaPlayerControls, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return MediaPlayerControls