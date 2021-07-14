local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Tooltip = UI.Tooltip
local Button = UI.Button
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel

return {
	stories = {
		{
			name = "For label",
			story = Roact.createElement(TextLabel, {
				Text = "Hover over this text",
				Size = UDim2.new(1, 0, 0, 20)
			}, {
				Tooltip = Roact.createElement(Tooltip, {
					Text = "An example tooltip"
				})
			}),
		}, {
			name = "For button",
			story = Roact.createElement(Button, {
				Text = "Hover over this button",
				Size = UDim2.new(1, 0, 0, 32),
				Style = "Round",
				OnClick = function() end,
			}, {
				Tooltip = Roact.createElement(Tooltip, {
					Text = "Some example which is really rather long indeed!"
				})
			}),
		}, {
			name = "For automatic size child",
			story = Roact.createElement(Tooltip, {
				Text = "Some example which is really rather long indeed!",
				Child = Roact.createElement(Pane, {
					Style = "BorderBox",
					Padding = 10,
				}, {
					Child = Roact.createElement(TextLabel, {
						Text = "Hover over this pane!",
						AutomaticSize = Enum.AutomaticSize.XY,
					})
				})
			}),
		}
	}
}
