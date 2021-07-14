local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local SpringAnimatedItem = require(script.Parent.SpringAnimatedItem)

local TestButton = Roact.PureComponent:extend("TestButton")

function TestButton:init()
	self.state = {
		activated = false,
	}

	self.ref = Roact.createRef()
end

function TestButton:render()
	local activated = self.state.activated

	return Roact.createElement(SpringAnimatedItem.AnimatedTextButton, {
		animatedValues = {
			backgroundTransparency = activated and 0 or 0.5,
			height = activated and 200 or 100,
			positionOffsetY = activated and 200 or 0,
		},
		mapValuesToProps = function(values)
			return {
				BackgroundTransparency = values.backgroundTransparency,
				Size = UDim2.new(0, 200, 0, values.height),
				Position = UDim2.new(0, 0, 0, values.positionOffsetY),
			}
		end,
		regularProps = {
			Text = "SpringAnimatedItem",
			Size = UDim2.new(0, 200, 0, 0),
			BackgroundColor3 = Color3.fromRGB(2, 183, 87),
			AutoButtonColor = false,
			[Roact.Event.Activated] = function()
				self:setState({
					activated = not self.state.activated,
				})

				-- Change the text here, to verify that ref forwarding works properly.
				self.ref.current.Text = self.state.activated
					and "SpringAnimatedItem - Activated" or "SpringAnimatedItem"
			end,
			[Roact.Ref] = self.ref,
		},
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(TestButton), target, "SpringAnimatedItem")

	return function()
		Roact.unmount(handle)
	end
end
