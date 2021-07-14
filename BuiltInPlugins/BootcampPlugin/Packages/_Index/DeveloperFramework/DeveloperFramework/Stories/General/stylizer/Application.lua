--[[
	Application

]]
local Framework = script.Parent.Parent.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local Button = require(script.Parent.Button)
local Dialog = require(script.Parent.Dialog)
local Stylizer = require(Framework.Style).Stylizer

-- Application
local Application = Roact.PureComponent:extend("Application")

function Application:init()
	self.state = {
		className = "Important"
	}

	self.changeStyle = function()
		local c = "Sub"
		if self.state.className == c then
			c = "Important"
		end
		self:setState({
			className = c
		})
	end
end

function Application:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 20),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Dialog1 = Roact.createElement(Dialog, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(300, 150),
			Style = self.state.className,
		}),

		Dialog2 = Roact.createElement(Dialog, {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(300, 150),
		}),

		Button = Roact.createElement(Button, {
			LayoutOrder = 3,
			Size = UDim2.fromOffset(300, 60),
			Text = "Click to change Style prop for Dialog 2",
			OnClick = self.changeStyle,
		})
	})
end

ContextServices.mapToProps(Application, {
	Stylizer = Stylizer
})

return Application