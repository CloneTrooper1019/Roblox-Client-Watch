local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")

local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local Checkbox = UI.Checkbox
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel

local Checkboxes = Roact.PureComponent:extend("Checkboxes")

function Checkboxes:init()
	self.state = {
		KEY1 = false,
		KEY2 = false,
		KEY3 = Checkbox.Indeterminate,
		KEY4 = true,
	}

	self.onClick = function(key)
		self:setState({
			[key] = not self.state[key]
		})
	end
end

function Checkboxes:render()
	if FFlagDevFrameworkCheckbox then
		return Roact.createElement(Pane, {
			AutomaticSize = Enum.AutomaticSize.Y,
			Layout = Enum.FillDirection.Vertical,
			Padding = 10,
			Spacing = 15
		}, {
			Disabled = Roact.createElement(Checkbox, {
				Checked = self.state["KEY1"],
				Disabled = true,
				Key = "KEY1",
				LayoutOrder = 1,
				OnClick = self.onClick,
				Text = "Disabled",
			}),
			Default = Roact.createElement(Checkbox, {
				Checked = self.state["KEY2"],
				Key = "KEY2",
				LayoutOrder = 2,
				OnClick = self.onClick,
				Text = "Clickable",
			}),
			Indeterminate = Roact.createElement(Checkbox, {
				Checked = self.state["KEY3"],
				Key = "KEY3",
				LayoutOrder = 3,
				OnClick = self.onClick,
				Text = "Mixed",
			}),
			NoLabel = Roact.createElement(Checkbox, {
				Checked = self.state["KEY4"],
				Key = "KEY4",
				LayoutOrder = 4,
				OnClick = self.onClick,
			}),
		})
	else
		return Roact.createElement(Pane, {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}, {
			Label = Roact.createElement(TextLabel, {
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = "Not quite ready. Will be released soon!",
				TextWrapped = true,
			}),

		})
	end
end

return Checkboxes
