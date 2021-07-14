local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local RoundBox = UI.Decoration.RoundBox
local Container = UI.Container

return Roact.createElement(Container, {
	Size = UDim2.fromOffset(100, 100),
}, {
	Decoration = Roact.createElement(RoundBox)
})
