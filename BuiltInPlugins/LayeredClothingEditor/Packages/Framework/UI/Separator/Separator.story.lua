local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Container = UI.Container
local Separator = UI.Separator

return Roact.createElement(Container, {
	Size = UDim2.new(1, -30, 0, 40)
}, {
	Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
	}),
	Roact.createElement("TextLabel", {
		Text = "Line 1",

	}),
	Roact.createElement(Separator, {}),
	Roact.createElement("TextLabel", {
		Text = "Line 2",

	})
})
