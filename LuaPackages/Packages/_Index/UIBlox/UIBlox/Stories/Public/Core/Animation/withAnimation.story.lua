local Packages = script:FindFirstAncestor("UIBlox").Parent

local UIBlox = require(Packages.UIBlox)
local Roact = require(Packages.Roact)

local withAnimation = UIBlox.Core.Animation.withAnimation

local Story = Roact.Component:extend("Story")

function Story:init()
	self:setState({
		activated = false,
	})

	self.toggle = function()
		self:setState({
			activated = not self.state.activated,
		})
	end
end

function Story:render()
	local activated = self.state.activated

	return withAnimation({
		backgroundTransparency = activated and 0 or 0.5,
		height = activated and 200 or 100,
		positionOffsetY = activated and 200 or 0,
	}, function(values)
		return Roact.createElement("TextButton", {
			Text = activated and "TextButton withAnimation - Activated" or "TextButton withAnimation",
			BackgroundColor3 = Color3.fromRGB(2, 183, 87),
			AutoButtonColor = false,
			[Roact.Event.Activated] = self.toggle,
			-- animated values
			BackgroundTransparency = values.backgroundTransparency,
			Size = UDim2.new(0, 200, 0, values.height),
			Position = UDim2.new(0, 0, 0, values.positionOffsetY),
		})
	end)
end

return {
	summary = "Similar to SpringAnimatedItem, using withAnimation instead",
	story = Story,
}
