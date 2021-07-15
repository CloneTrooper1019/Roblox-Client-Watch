local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local ExpandableWidget = UI.ExpandableWidget

local Example = Roact.PureComponent:extend(script.Parent.Name .. "Example")

function Example:init()
	self.state = {
		isExpanded = false
	}
	self.toggleExpansion = function()
		self:setState({
			isExpanded = (not self.state.isExpanded)
		})
	end
end

function Example:render()
	return Roact.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(0, 240, 0, 32)
	}, {
		ExpandableWidget = Roact.createElement(ExpandableWidget, {
			IsExpanded = self.state.isExpanded,
			LayoutOrder = 0,
			TopLevelContent = {
				Roact.createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.new(1, 0, 0),
					Size = UDim2.new(0, 240, 0, 32),
					Text = "TopLevelItem",
				})
			},
			ExpandableContent = {
				Roact.createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.new(0, 1, 0),
					Size = UDim2.new(0, 240, 0, 32),
					Text = "ExpandableContent",
				})
			},
			OnClick = self.toggleExpansion,
		}),
	})
end

return Example