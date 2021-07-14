local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)

return function(props)
	return Roact.createElement("Frame", {
		BackgroundColor3 = props.color,
		Size = UDim2.new(0, props.width, 0, props.width),
		LayoutOrder = props.LayoutOrder,
	})
end