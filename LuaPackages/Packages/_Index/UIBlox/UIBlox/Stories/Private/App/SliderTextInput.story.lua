local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local SliderTextInput = require(App.Slider.SliderTextInput)

local Story = Roact.PureComponent:extend("Story")

function Story:init()
	self:setState({
		value = 10
	})
end

function Story:render()
	return Roact.createFragment({
		List = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Normal = Roact.createElement(SliderTextInput, {
			layoutOrder = 1,
			value = self.state.value,
			min = 0,
			max = 100,
			stepInterval = 10,
			onValueChanged = function(newValue)
				print(newValue)
				self:setState({
					value = newValue,
				})
			end,
		}),
		Disabled = Roact.createElement(SliderTextInput, {
			layoutOrder = 2,
			value = self.state.value,
			min = 0,
			max = 100,
			stepInterval = 10,
			disabled = true,
			onValueChanged = function(newValue)
			end,
		}),
	})
end

return Story