local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)

local Core = Packages.UIBlox.Core
local GenericSlider = require(Core.Slider.GenericSlider)

local Story = Roact.PureComponent:extend("Story")

function Story:init()
	self:setState({
		value = 50,
		drag = false,
	})
end

function Story:render()
	return Roact.createElement(GenericSlider, {
		lowerValue = self.state.value,
		min = 0,
		max = 100,
		stepInterval = 10,
		isDisabled = false,

		onValueChanged = function(value)
			print("New slider value:", value)
			self:setState({
				value = value,
			})
		end,
		onDragStartLower = function()
			self:setState({
				drag = true,
			})
		end,
		onDragEnd = function()
			self:setState({
				drag = false,
			})
		end,

		trackImage = Images["component_assets/circle_16"],
		trackTransparency = 0,
		trackSliceCenter = Rect.new(8, 8, 8, 8),
		trackColor = Color3.new(0, 0, 0),

		trackFillImage = Images["component_assets/circle_16"],
		trackFillColor = Color3.new(1, 0, 0),
		trackFillSliceCenter = Rect.new(8, 8, 8, 8),
		trackFillTransparency = 0,

		knobImage = Images["component_assets/circle_28_padding_10"],
		knobColorLower = Color3.new(0.8, 0.8, 0.8),
		knobTransparency = 0,

		knobImagePadding = 0,

		knobShadowImage = Images["component_assets/dropshadow_28"],
		knobShadowTransparencyLower = self.state.drag and 1 or 0,

		position = UDim2.fromScale(0.5, 0.5),
		width = UDim.new(0.8, 0),
		anchorPoint = Vector2.new(0.5, 0.5),
	})
end

return Story