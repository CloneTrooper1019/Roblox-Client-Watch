local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local IconButton = UI.IconButton
local Pane = UI.Pane

local onClick = function()
	print("IconButton clicked")
end

return function()
	return Roact.createElement(Pane, {
		Size = UDim2.fromOffset(500, 500),
		Layout = Enum.FillDirection.Vertical,
		Spacing = 10,
	}, {
		MyButton = Roact.createElement(IconButton, {
			Text = "Text",
			LeftIcon = "rbxasset://textures/ui/common/robux_color@2x.png",
			OnClick = onClick,
		}),
		BlueButton = Roact.createElement(IconButton, {
			Size = UDim2.fromOffset(50, 50),
			BackgroundColor = Color3.fromRGB(126, 222, 251),
			OnClick = onClick,
		}),
		Disabled = Roact.createElement(IconButton, {
			Text = "Disabled",
			Disabled = true,
		}),
		IconOnly = Roact.createElement(IconButton, {
			Size = UDim2.fromScale(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			LeftIcon = "rbxasset://textures/ui/common/robux_color@2x.png",
			OnClick = onClick,
		}),
		NoOnClick = Roact.createElement(IconButton, {
			Size = UDim2.fromOffset(200, 50),
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = "No OnClick Passed",
		}),
		RightIcon = Roact.createElement(IconButton, {
			Size = UDim2.fromOffset(100, 50),
			Text = "Text",
			RightIcon = "rbxasset://textures/ui/common/robux_color@2x.png",
			TextXAlignment = Enum.TextXAlignment.Right,
			OnClick = onClick,
		}),
	})
end
