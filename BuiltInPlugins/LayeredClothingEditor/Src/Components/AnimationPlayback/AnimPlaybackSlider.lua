--[[
	Animation playback slider wrapping around DevFramework slider.
	Contains a play button to the left and a timer label to the right of the slider.

	Required Props:
		UDim2 Size: size of the frame
		boolean IsPlaying: if animation is playing or pausing, which is provided via store
		number Playhead: position of the current anim, which is provided via store
		callback SetSliderPlayhead: function to set the playhead by slider, which is provided via mapDispatchToProps.
		callback SetIsPlaying: function to set is animation is playing, which is provided via mapDispatchToProps.

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number TrackLength: length of the current track, which is provided via store
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator

local UI = Framework.UI
local Slider = UI.Slider
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel

local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)
local SetSliderPlayhead = require(Plugin.Src.Actions.SetSliderPlayhead)

local AnimPlaybackSlider = Roact.PureComponent:extend("AnimPlaybackSlider")

local Typecheck = Util.Typecheck
Typecheck.wrap(AnimPlaybackSlider, script)

local timeTextFormat = "%.2f"

function AnimPlaybackSlider:init()
	self.onValueChanged = function(value)
		self.props.SetSliderPlayhead(value)
	end
end

function AnimPlaybackSlider:render()
	local props = self.props
	local size = props.Size
	local playhead = props.Playhead or 0
	local isPlaying = props.IsPlaying
	local maxValue = props.TrackLength or 0
	local endFrameText = string.format(timeTextFormat, maxValue)
	local currentFrameText = string.format(timeTextFormat, playhead)
	local isDisabled = maxValue <= 0
	local orderIterator = LayoutOrderIterator.new()

	local theme = props.Stylizer
	local playIamge = theme.PlayImage
	local pauseImage = theme.PauseImage
	return Roact.createElement(Pane, {
		Size = size,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Spacing = theme.Padding,
	}, {
		PlayPauseButton = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderColor3 = theme.BorderColor,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, theme.PlayButtonWidth, 0, theme.PlayButtonWidth),
			Image = isPlaying and pauseImage or playIamge,
			AutoButtonColor = false,
			LayoutOrder = orderIterator:getNextOrder(),
			[Roact.Event.Activated] = function ()
				local isEnabled = props.TrackLength and props.TrackLength > 0
				if isEnabled then
					props.SetIsPlaying(not isPlaying)
				end
			end,
		}),

		ValueSlider = Roact.createElement(Slider, {
			Disabled = isDisabled,
			Min = 0,
			Max = maxValue,
			Value = playhead,
			Size = UDim2.new(1, -theme.PlayButtonWidth - theme.PlayTimeLabelWidth - theme.Padding, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
			OnValueChanged = self.onValueChanged,
		}),

		PlayTimeLabel = Roact.createElement(TextLabel, {
			Text = currentFrameText .. " / " .. endFrameText,
			TextColor = isDisabled and theme.TextDisabledColor or theme.TextColor,
			Size = UDim2.new(0, theme.PlayTimeLabelWidth, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
		}),
	})
end

ContextServices.mapToProps(AnimPlaybackSlider,{
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
	local animation = state.animation
	return {
		IsPlaying = animation.IsPlaying,
		Playhead = animation.Playhead,
		TrackLength = animation.TrackLength,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetIsPlaying = function(isPlaying)
			dispatch(SetIsPlaying(isPlaying))
		end,
		SetSliderPlayhead = function(sliderPlayhead)
			dispatch(SetSliderPlayhead(sliderPlayhead))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(AnimPlaybackSlider)
