local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local FakeLoadingBar = UI.FakeLoadingBar

return Roact.createElement(FakeLoadingBar, {
	LoadingTime = 5,
	Size = UDim2.fromOffset(120, 8),
})
