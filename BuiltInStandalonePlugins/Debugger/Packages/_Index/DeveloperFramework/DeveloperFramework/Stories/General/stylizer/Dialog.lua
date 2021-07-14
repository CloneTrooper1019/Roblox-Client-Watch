--[[
	Dialog
]]

local Framework = script.Parent.Parent.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local Stylizer = require(Framework.Style).Stylizer
local Box = require(script.Parent.Box)

-- In the component
local Dialog = Roact.PureComponent:extend("Dialog")

function Dialog:render()
	local style = self.props.Stylizer

	return Roact.createElement("Frame", {
		Size = self.props.Size,
		Position = self.props.Position,
		BackgroundColor3 = style.BackgroundColor,
		BackgroundTransparency = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		FrontText = Roact.createElement("TextLabel", {
			Text = style:getPathString(),
			Size = UDim2.new(1, 0, 1, -60),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			TextColor3 = style.TextColor3,
		}),

		Box = Roact.createElement(Box, {
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.new(1, -20, 0, 100),
		})
	})
end

ContextServices.mapToProps(Dialog, {
	Stylizer = Stylizer
})

return Dialog
