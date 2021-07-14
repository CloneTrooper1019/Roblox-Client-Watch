local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local HorizontalPageMargin = require(App.Container.HorizontalPageMargin)

return Roact.createElement(HorizontalPageMargin, {
	backgroundColor3 = Color3.fromRGB(150, 10, 150),
}, {
	text = Roact.createElement("TextLabel", {
		Text = "Hello",
		Size = UDim2.fromScale(1, 1),
	})
})

