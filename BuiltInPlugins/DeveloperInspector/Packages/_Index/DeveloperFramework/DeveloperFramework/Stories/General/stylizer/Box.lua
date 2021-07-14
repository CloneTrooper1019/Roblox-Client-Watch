--[[
	Box
]]

local Framework = script.Parent.Parent.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local Stylizer = require(Framework.Style).Stylizer

-- In the component
local Box = Roact.PureComponent:extend("Box")

function Box:render()
	local style = self.props.Stylizer

	return Roact.createElement("Frame", {
		Size = self.props.Size,
		Position = self.props.Position,
		BorderSizePixel = 0,
		BackgroundColor3 = style.BackgroundColor,
		BackgroundTransparency = 0,
		LayoutOrder = self.props.LayoutOrder or 0,
	}, {
		FrontText = Roact.createElement("TextLabel", {
			Text = style:getPathString(),
			Size = UDim2.new(1, 0, 1, -60),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			TextColor3 = style.TextColor3,
		}),
	})
end

ContextServices.mapToProps(Box, {
	Stylizer = Stylizer
})

return Box