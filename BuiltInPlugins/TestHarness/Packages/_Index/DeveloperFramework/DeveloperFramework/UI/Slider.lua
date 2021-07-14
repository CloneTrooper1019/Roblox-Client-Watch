--[[
	A slider with one knob to allow selection of a value within a range.

	Required Props:
		number Min: Min value of the slider
		number Max: Max value of the slider
		number Value: Current value for the knob
		callback OnValueChanged: The callback is called whenever the value changes - OnValueChanged(value: number)

	Optional Props:
		Vector2 AnchorPoint: The anchorPoint of the component
		boolean Disabled: Whether to render in the enabled/disabled state
		number LayoutOrder: The layoutOrder of the component
		UDim2 Position: The position of the component
		UDim2 Size: The size of the component
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		number SnapIncrement: Incremental points that the slider's knob will snap to. A "0" snap increment means no snapping.
		number VerticalDragTolerance: A vertical pixel height for allowing a mouse button press to drag the knob on outside the component's size.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Util = require(Framework.Util)
local Immutable = Util.Immutable
local Typecheck = Util.Typecheck

local UI = Framework.UI
local RangeSlider = require(UI.RangeSlider)

local Slider = Roact.PureComponent:extend("Slider")
Typecheck.wrap(Slider, script)

function Slider:render()
	local props = self.props

	local rangedSliderProps = Immutable.JoinDictionaries(
		Immutable.RemoveFromDictionary(props, "Value", "OnValueChanged"),
		{
			HideLowerKnob = true,
			LowerRangeValue = props.Min,
			UpperRangeValue = props.Value,
			OnValuesChanged = function(minValue, maxValue)
				if self.props.OnValueChanged then
					self.props.OnValueChanged(maxValue)
				end
			end
		}
	)

	return Roact.createElement(RangeSlider, rangedSliderProps)
end

return Slider