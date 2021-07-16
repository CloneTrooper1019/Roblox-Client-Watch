local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Container = require(Framework.UI.Container)
local HoverArea = require(Framework.UI.HoverArea)

return Roact.createElement(Container, {
	Size = UDim2.new(1, 0, 0, 300)
}, {
	BottomLabel = Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 100, 0, 60),
		Text = "Priority 1\nPointingHand",
		Position = UDim2.new(0.5, 0, 0.5, -25),
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		HoverArea = Roact.createElement(HoverArea, {
			Cursor = "PointingHand",
		})
	}),

	TopLabel = Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 100, 0, 60),
		Text = "Priority 2\nOpenHand",
		Position = UDim2.new(0.5, 20, 0.5, 25),
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		HoverArea = Roact.createElement(HoverArea, {
			Cursor = "OpenHand",
			Priority = 2,
		})
	}),
})
