local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)

local Thing = Roact.PureComponent:extend("Thing")

function Thing:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = self.props.color,
		Size = UDim2.new(0, self.props.width, 0, self.props.width),
		LayoutOrder = self.props.LayoutOrder,
	})
end

local ThingRoot = Roact.PureComponent:extend("ThingRoot")

function ThingRoot:render()
	return Roact.createElement(Thing, {
		color = self.props.color,
		width = self.props.width,
		LayoutOrder = self.props.LayoutOrder,
	})
end

return ThingRoot
