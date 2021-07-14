--[[
	Formatted slider wrapping around DevFramework slider. Contains a label to the left and
	a text input box to the right of the slider.

	Required Props:
		string Title: label text to the left of the slider
		number Value: slider value
		number MaxValue: maximum value of the slider
		UDim2 Size: size of the component
		boolean UsePercentage: if slider value should display as a percentage
		number LayoutOrder: sort order of frame in a layout
		callback SetValue: function to be called when slider value has changed
		boolean IsDisabled: whether this slider setting is disabled
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number SnapIncrement: optional increment when dragging slider. Default to 1
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local Slider = UI.Slider
local TextInput = UI.TextInput
local TextLabel = UI.Decoration.TextLabel
local Pane = UI.Pane

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local StyleModifier = Util.StyleModifier

local SliderSetting = Roact.PureComponent:extend("SliderSetting")

local Typecheck = Util.Typecheck
Typecheck.wrap(SliderSetting, script)

function SliderSetting:init(initialProps)
	self.state = {
		valueText = tostring(initialProps.Value),
	}
	self.previoustPropsValue = initialProps.Value
	self.onValueChanged = function(value)
		if self.props.SetValue then
			self.props.SetValue(value)
		end
	end

	self.onTextChanged = function(text)
		self:setState({
			valueText = text
		})
	end

	self.onTextSubmitted = function()
		local success, result = pcall(function()
			return tonumber(self.state.valueText)
		end)
		if success and result then
			self.onValueChanged(math.clamp(result, 0, self.props.MaxValue))
		else
			self.onValueChanged(0)
		end
	end
end

function SliderSetting:render()
	local props = self.props
	local state = self.state

	local title = props.Title
	local value = props.Value
	self.previoustPropsValue = value
	local maxValue = props.MaxValue
	local size = props.Size
	local usePercentage = props.UsePercentage
	local layoutOrder = props.LayoutOrder
	local isDisabled = props.IsDisabled
	local orderIterator = LayoutOrderIterator.new()
	local theme = props.Stylizer

	local snapIncrement = props.SnapIncrement or theme.DefaultSnap
	local valueText = self.previoustPropsValue == value and state.value or value
	if snapIncrement == theme.DefaultSnap then
		valueText = string.format("%d", valueText)
	else
		valueText = string.format("%" ..snapIncrement .."f", valueText)
	end

	local labelWidth = theme.LabelWidth
	local sliderContainerWidth = - theme.SliderContainerPadding - labelWidth
	local inputWidth = theme.InputWidth
	local inputHeight = theme.InputHeight
	local inputFrameWidth = theme.PercentageLabelWidth + theme.ValueTextBoxPadding + theme.InputWidth
	local sliderWidth = - inputFrameWidth - theme.SliderContainerPadding

	return Roact.createElement(Pane, {
		LayoutOrder = layoutOrder,
		Size = size,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Spacing = theme.SliderContainerPadding,
	}, {
		Label = Roact.createElement(TextLabel, {
			Text = title,
			StyleModifier = isDisabled and StyleModifier.Disabled or nil,
			Size = UDim2.new(0, labelWidth, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
		}),
		SliderContainer = Roact.createElement(Pane, {
			Size = UDim2.new(1, sliderContainerWidth, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
			Layout = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Spacing = theme.SliderContainerPadding,
		}, {
			ValueSlider = Roact.createElement(Slider, {
				Disabled = isDisabled,
				Min = 0,
				Max = maxValue,
				Value = value,
				SnapIncrement = snapIncrement,
				Size = UDim2.new(1, sliderWidth, 1, 0),
				LayoutOrder = orderIterator:getNextOrder(),
				OnValueChanged = self.onValueChanged,
			}),
			ValueTextBoxFrame = Roact.createElement(Pane, {
				LayoutOrder = orderIterator:getNextOrder(),
				Size = UDim2.new(0, inputFrameWidth, 1, 0),
				BackgroundColor3 = theme.BackgroundColor,
				Layout = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Spacing = theme.ValueTextBoxPadding,
			}, {
				ValueTextBox = Roact.createElement(TextInput, {
					Enabled = not isDisabled,
					LayoutOrder = orderIterator:getNextOrder(),
					Text = valueText,
					Size = UDim2.new(0, inputWidth, 0, inputHeight),
					OnTextChanged = self.onTextChanged,
					OnFocusLost = self.onTextSubmitted,
					Style = "RoundedBorder",
					StyleModifier = isDisabled and StyleModifier.Disabled or nil
				}),

				PercentageLabel = usePercentage and Roact.createElement(TextLabel, {
					Text = "%",
					StyleModifier = isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.new(0, theme.PercentageLabelWidth, 1, 0),
					LayoutOrder = orderIterator:getNextOrder(),
				}),
			}),
		}),
	})
end

ContextServices.mapToProps(SliderSetting,{
	Stylizer = ContextServices.Stylizer,
})

return SliderSetting