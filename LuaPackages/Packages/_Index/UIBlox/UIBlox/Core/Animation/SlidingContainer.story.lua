-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\Animation\SlidingContainer.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local SlidingContainer = require(script.Parent.SlidingContainer)
local SlidingDirection = require(script.Parent.Enum.SlidingDirection)

local SlidingContainerComponent = Roact.PureComponent:extend("SlidingContainerComponent")

function SlidingContainerComponent:init()
	self.state = {
		show = false,
	}

	self.buttonRef = Roact.createRef()
end

function SlidingContainerComponent:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
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