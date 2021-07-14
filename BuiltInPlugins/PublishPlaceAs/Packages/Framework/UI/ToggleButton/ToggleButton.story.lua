local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")

local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local Pane = UI.Pane
local ToggleButton = UI.ToggleButton

local ExampleToggleButton = Roact.PureComponent:extend("ExampleToggleButton")

function ExampleToggleButton:init()
	self.state = {
		toggleOn1 = true,
		toggleOn2 = true,
	}
	self.onToggle1 = function()
		self:setState({
			toggleOn1 = (not self.state.toggleOn1),
		})
	end
	if not FFlagDevFrameworkCheckbox then
		self.onToggle2 = function()
			self:setState({
				toggleOn2 = (not self.state.toggleOn2),
			})
		end
	end
end

function ExampleToggleButton:render()
	return  Roact.createElement(Pane, {
		Layout = Enum.FillDirection.Vertical,
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = 10,
		Spacing = 15,
	}, {
		DisabledToggle = Roact.createElement(ToggleButton, {
			Disabled = true,
			Selected = false,
			LayoutOrder = 0,
			OnClick = self.onToggle1,
			Size = UDim2.fromOffset(40, 24),
		}),
		ToggleButton = Roact.createElement(ToggleButton, {
			Disabled = false,
			Selected = self.state.toggleOn1,
			LayoutOrder = 1,
			OnClick = self.onToggle1,
			Size = UDim2.fromOffset(40, 24),
		}),
		CheckboxToggle = not FFlagDevFrameworkCheckbox and Roact.createElement(ToggleButton, {
			Disabled = false,
			Selected = self.state.toggleOn2,
			LayoutOrder = 2,
			OnClick = self.onToggle2,
			Size = UDim2.fromOffset(20, 20),
			Style = "Checkbox",
		}) or nil,
	})
end

return ExampleToggleButton
