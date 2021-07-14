local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local Core = Packages.UIBlox.Core
local SlidingContainer = require(Core.Animation.SlidingContainer)
local SlidingDirection = require(Core.Animation.Enum.SlidingDirection)

local SlidingContainerComponent = Roact.PureComponent:extend("SlidingContainerComponent")

function SlidingContainerComponent:init()
	self.state = {
		show = false,
	}

	self.buttonRef = Roact.createRef()
end

function SlidingContainerComponent:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 500),
		BackgroundTransparency = 1,
	}, {
		SlidingContainer = Roact.createElement(SlidingContainer, {
			show = self.state.show,
			slidingDirection = SlidingDirection.Down,
		}, {
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
			})
		}),
		ControlButton = Roact.createElement("TextButton", {
			BackgroundColor3 = Color3.fromRGB(2, 183, 87),
			Size = UDim2.new(0, 200, 0, 50),
			Text = "Page slide down",
			ZIndex = 2,
			[Roact.Event.Activated] = function()
				self:setState({
					show = not self.state.show,
				})
				self.buttonRef.current.Text = self.state.show
					and "Page slide up" or "Page slide down"
			end,
			[Roact.Ref] = self.buttonRef,
		})
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(SlidingContainerComponent), target, "SlidingContainer")

	return function()
		Roact.unmount(handle)
	end
end