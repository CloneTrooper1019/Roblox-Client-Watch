local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local Pane = UI.Pane
local RadioButtonList = UI.RadioButtonList

-- Mount and display a dialog
local ExampleRadioButtonList = Roact.PureComponent:extend("ExampleRadioButtonList")

function ExampleRadioButtonList:init()
	self.state = {
		isSelected = true,
	}
	self.onClick = function()
		self:setState({
			isSelected = (not self.state.isSelected)
		})
	end
end

function ExampleRadioButtonList:render()
	return Roact.createElement(Pane, {
		Layout = Enum.FillDirection.Vertical,
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = 10,
		Spacing = 15,
	}, {
		VerticalList = Roact.createElement(RadioButtonList, {
			Buttons = {
				{
					Key = "KEY1",
					Text = "option text 1",
				},
				{
					Key = "KEY2",
					Text = "option text 2",
					Disabled = false,
				},
				{
					Key = "KEY3",
					Text = "option text 3",
					Disabled = false,
				},
				{
					Key = "KEY4",
					Text = "disabled text",
					Disabled = true,
				},
			},
			FillDirection = Enum.FillDirection.Vertical,
			LayoutOrder = 1,
			OnClick = self.onClick,
			SelectedKey = "KEY1",
		}),
		HorizontalList = Roact.createElement(RadioButtonList, {
			Buttons = {
				{
					Key = "KEY1",
					Text = "option text 1",
					Disabled = false,
				},
				{
					Key = "KEY2",
					Text = "option text 2",
					Disabled = false,
				},
				{
					Key = "KEY4",
					Text = "disabled text",
					Disabled = true,
				},
			},
			FillDirection = Enum.FillDirection.Horizontal,
			LayoutOrder = 2,
			OnClick = self.onClick,
			SelectedKey = "KEY2",
		}),
	})
end

return ExampleRadioButtonList
