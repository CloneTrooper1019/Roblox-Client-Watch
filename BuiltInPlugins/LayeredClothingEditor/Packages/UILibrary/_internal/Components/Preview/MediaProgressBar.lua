--[[
	A one-knob slider
	TODO: DEVTOOLS-4330 - Replace this entire component with DevFramework's one-knob slider once assetPreview is out of UILibrary

	Required Props:
		number Min: Min value of the slider
		number Max: Max value of the slider
		number CurrentValue: Current value for the lower range handle
		callback OnValuesChanged: A callback that takes in params: minValue, maxValue. The callback is called whenever the min or max value changes.

	Optional Props:
		Vector2 AnchorPoint: The anchorPoint of the component
		boolean Disabled: Whether to render in the enabled/disabled state
		number LayoutOrder: The layoutOrder of the component
		UDim2 Position: The position of the component
		number SnapIncrement: Incremental points that the slider's knob will snap to. A "0" snap increment means no snapping.
		number VerticalDragTolerance: A vertical pixel height for allowing a pressed mouse to drag knobs on outside the component's size.

]]
local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local PROGRESS_BAR_HEIGHT = 6
local knobSize = Vector2.new(15, 15)

local MediaProgressBar = Roact.PureComponent:extend("MediaProgressBar")

local function isUserInputTypeClick(inputType)
	return (inputType == Enum.UserInputType.Touch) or (inputType == Enum.UserInputType.MouseButton1)
end

MediaProgressBar.defaultProps = {
	Disabled = false,
	Size = UDim2.new(1, 0, 1, 0),
	SnapIncrement = 0,
	VerticalDragTolerance = 300,
}

function MediaProgressBar:init()
	self.sliderFrameRef = Roact.createRef()

	self.state = {
		pressed = false
	}

	self.getTotalRange = function()
		return self.props.Max - self.props.Min
	end

	self.getSnappedValue = function(value)
		local snapIncrement = self.props.SnapIncrement
		local min = self.props.Min
		local max = self.props.Max

		if snapIncrement > 0 then
			local prevSnap = math.max(snapIncrement * math.floor(value / snapIncrement), min)
			local nextSnap = math.min(prevSnap + snapIncrement, max)
			return math.abs(prevSnap-value) < math.abs(nextSnap-value) and prevSnap or nextSnap
		end

		return math.clamp(value, min, max)
	end

	self.getMouseClickValue = function(input)
		local sliderFrameRef = self.sliderFrameRef.current
		local inputHorizontalOffsetNormalized = (input.Position.X - sliderFrameRef.AbsolutePosition.X) / sliderFrameRef.AbsoluteSize.X
		inputHorizontalOffsetNormalized = math.clamp(inputHorizontalOffsetNormalized, 0, 1)
		local valueBeforeSnapping = self.props.Min + (inputHorizontalOffsetNormalized * self.getTotalRange())

		return self.getSnappedValue(valueBeforeSnapping)
	end

	self.setValuesFromInput = function(input)
		local mouseClickValue = self.getMouseClickValue(input)
		local clampedValue = math.clamp(mouseClickValue, self.props.Min, self.props.Max)

		self.props.OnValuesChanged(clampedValue)
	end

	self.onInputBegan = function(rbx, input)
		if self.props.Disabled then
			return

		elseif isUserInputTypeClick(input.UserInputType) then
			self:setState({
				pressed = true,
			})
			self.setValuesFromInput(input)
		end
	end

	self.onInputChanged = function(rbx, input)
		if self.props.Disabled then
			return

		elseif self.state.pressed and input.UserInputType == Enum.UserInputType.MouseMovement then
			self.setValuesFromInput(input)
		end
	end

	self.onInputEnded = function(rbx, input)
		if not self.props.Disabled and isUserInputTypeClick(input.UserInputType) then
			self.props.OnInputEnded()
			self:setState({
				pressed = false,
			})
		end
	end
end

function MediaProgressBar:render()
	return withTheme(function(theme)
		local audioPreviewTheme = theme.assetPreview.audioPreview

		local anchorPoint = self.props.AnchorPoint
		local isDisabled = self.props.Disabled
		local currentValue = self.props.CurrentValue
		local layoutOrder = self.props.LayoutOrder
		local min = self.props.Min
		local position = self.props.Position
		local verticalDragBuffer = self.props.VerticalDragTolerance

		local lowerFillPercent = (currentValue - min) / self.getTotalRange()

		return Roact.createElement("Frame", {
			AnchorPoint = anchorPoint,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Position = position,
			Size = UDim2.new(1, 0, 0, knobSize.X),

			[Roact.Ref] = self.sliderFrameRef,
		}, {
			ProgressBarBackground = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = audioPreviewTheme.progressBar_BG_Color,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, PROGRESS_BAR_HEIGHT),
			}, {
				ProgressBarForeground = Roact.createElement("Frame", {
					BackgroundColor3 = audioPreviewTheme.progressBar,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Size = UDim2.new(lowerFillPercent, 0, 1, 0),
				}),
			}),

			Knob = Roact.createElement("ImageButton", {
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Image = audioPreviewTheme.progressKnob,
				ImageColor3 = audioPreviewTheme.progressKnobColor,
				Position = UDim2.new(lowerFillPercent, 0, 0.5, 0),
				Size = UDim2.new(0, knobSize.X, 0, knobSize.Y),
				ZIndex = 3,
			}),

			ClickHandler = (not isDisabled) and Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, knobSize.X, 1, self.state.pressed and verticalDragBuffer or 0),
				ZIndex = 4,

				[Roact.Event.InputBegan] = self.onInputBegan,
				[Roact.Event.InputChanged] = self.onInputChanged,
				[Roact.Event.InputEnded] =  self.onInputEnded,
			}),
		})
	end)
end

return MediaProgressBar