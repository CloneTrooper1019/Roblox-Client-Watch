local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Image = UI.Decoration.Image
local Container = UI.Container

return Roact.createElement(Container, {
	Size = UDim2.fromOffset(100, 100),
}, {
	Decoration = Roact.createElement(Image, {
		Style = {
			Image = "rbxasset://textures/ui/common/robux_color@2x.png",
		},
	})
})
