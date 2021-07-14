local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)

local Thing = Roact.PureComponent:extend("Thing")

function Thing:init()
	self.state = {
		clicked = false,
		token = nil,
	}
end

function Thing.getDerivedStateFromProps(nextProps, lastState)
	-- Use the token we're already being passed as a surrogate lock, just for this story.
	-- Normally, this would be a separate prop.
	if nextProps.token ~= lastState.token then
		return {
			clicked = false,
			token = nextProps.token,
		}
	end
end

function Thing:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = self.props.color,
		Size = UDim2.new(1, -self.props.width, 0, self.state.clicked and 10 or self.props.width),
		LayoutOrder = self.props.LayoutOrder,
		[Roact.Event.InputBegan] = function(rbx, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:setState({clicked = not self.state.clicked})
			end
		end,
	})
end

return Thing
