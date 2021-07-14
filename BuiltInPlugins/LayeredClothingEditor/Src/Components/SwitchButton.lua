--[[
	Shows a button which can be off or on

	Required Props:
		string Text: the text string on the button
		UDim2 Size: size of the frame
		boolean IsEnabled: if the button should be active/interactable
		callback OnClick: parameters() function to call when a button is clicked

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder: render order of component in layout
		number ZIndex: the z sorting order of the component
		boolean IsOn: is the switch button rendered in the switched on state
		string Image: the path to the icon image to be used
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UI = Framework.UI
local Button = UI.Button
local TextLabel = UI.Decoration.TextLabel

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local Typecheck = Util.Typecheck

local SwitchButton = Roact.PureComponent:extend("SwitchButton")
Typecheck.wrap(SwitchButton, script)

function SwitchButton:render()
	local props = self.props
	local size = self.props.Size
	local layoutOrder = props.LayoutOrder or 1
	local zIndex = props.ZIndex or 1
	local isOn = props.IsOn or false
	local text = props.Text
	local isEnabled = props.IsEnabled
	local onClick = props.OnClick
	local theme = props.Stylizer

	local orderIterator = LayoutOrderIterator.new()

	return Roact.createElement(Button, {
		Style = {
			Background = UI.Decoration.Box,
			BackgroundStyle = {
				Color = theme.BackgroundColor,
				BorderSize = 0,
			},
		},
		Size = size,
		LayoutOrder = layoutOrder,
		ZIndex = zIndex,
		OnClick = onClick,
	}, {
		TextLabel = Roact.createElement(TextLabel, {
			Style = {
				TextColor = isEnabled and theme.TextColor or theme.DisabledTextColor,
				TextSize = theme.TextSize,
				BackgroundTransparency = 1,
				Font = theme.Font,
				TextYAlignment = Enum.TextYAlignment.Center,
			},
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = zIndex,
			LayoutOrder = orderIterator:getNextOrder(),
			TextWrapped = true,
		}),
		TopLine = isOn and Roact.createElement("Frame", {
			BackgroundColor3 = theme.BorderSelectedColor,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = zIndex + 1,
		}),
		BottomLine = not isOn and Roact.createElement("Frame", {
			BackgroundColor3 = theme.BorderColor,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = zIndex + 1,
		}),
		LeftLine = isOn and Roact.createElement("Frame", {
			BackgroundColor3 = theme.BorderColor,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 1, 1, 0),
			ZIndex = zIndex + 1,
		}),
		RightLine = isOn and Roact.createElement("Frame", {
			BackgroundColor3 = theme.BorderColor,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -1, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			ZIndex = zIndex + 1,
		}),
	})
end

ContextServices.mapToProps(SwitchButton,{
	Stylizer = ContextServices.Stylizer,
})

return SwitchButton