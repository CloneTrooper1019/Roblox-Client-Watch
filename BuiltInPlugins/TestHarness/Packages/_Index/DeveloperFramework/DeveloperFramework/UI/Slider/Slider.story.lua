local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Slider = UI.Slider
local Container = UI.Container

return Roact.createElement(Container, {
	Size = UDim2.fromOffset(200, 20),
}, {
	Slider = Roact.createElement(Slider, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Disabled = false,
		Value = 4,
		Min = 0,
		Max = 4,
		OnValueChanged = function() end,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 200, 0, 20),
		SnapIncrement = 1,
		VerticalDragTolerance = 300,
	}),
})
