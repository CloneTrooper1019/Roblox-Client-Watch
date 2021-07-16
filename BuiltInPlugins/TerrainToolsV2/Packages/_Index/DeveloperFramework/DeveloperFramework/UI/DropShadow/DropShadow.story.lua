local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Container = UI.Container
local DropShadow = UI.DropShadow

return Roact.createElement("Frame", {
	Size = UDim2.new(0, 200, 0, 100),
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.new(1, 1, 1)
}, {
	Roact.createElement(Container, {
		Size = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}, {
		DropShadow = Roact.createElement(DropShadow, {}, {
			Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "Some text"
			}),
		})
	})
})