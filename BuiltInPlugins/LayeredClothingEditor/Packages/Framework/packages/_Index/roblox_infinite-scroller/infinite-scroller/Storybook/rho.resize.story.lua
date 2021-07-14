local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Bar = Roact.PureComponent:extend("Bar")

function Bar:init()
	self.state = {
		clicked = false,
	}
end

function Bar:render()
	return Roact.createElement("TextButton", Cryo.Dictionary.join(
		{
			Size = UDim2.new(1, 0, 0, self.state.clicked and 30 or 10),
			[Roact.Event.Activated] = function()
				self:setState({
					clicked = not self.state.clicked,
				})
			end,
		},
		self.props
	))
end

local Story = Roact.PureComponent:extend("Rhodium Story - frame resize test")

function Story:init()
	self.state = {
		size = Vector2.new(50, 50),
	}
end

function Story:render()
	return Roact.createElement("Frame", {
		Size=UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		scroll = Roact.createElement(Scroller, Cryo.Dictionary.join(
			{
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				Size = UDim2.new(0, self.state.size.X, 0, self.state.size.Y),
				padding = UDim.new(),
				itemList = {1, 2, 3},
				focusIndex = 2,
				anchorLocation = UDim.new(0, 0),
				orientation = Scroller.Orientation.Down,
				loadingBuffer = 2,
				mountingBuffer = 99,
				estimatedItemSize = 10,
				renderItem = function(item, _)
					return Roact.createElement(Bar, {
						BackgroundColor3 = item == 2
							and Color3.fromRGB(255, 255, 255)
							or Color3.fromRGB(0, -128 + 128*item, 376 - 128*item),
					}, {
						["INDEX" .. tostring(item)] = Roact.createElement("Frame"),
					})
				end,
			},
			self.props
		)),
		moveUp = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(0.5, -50, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			Text = "^",
			[Roact.Event.Activated] = function()
				self:setState({
					size = self.state.size + Vector2.new(0, -20)
				})
			end,
		}),
		moveDown = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(0.5, -50, 0, 100),
			AnchorPoint = Vector2.new(1, 0),
			Text = "v",
			[Roact.Event.Activated] = function()
				self:setState({
					size = self.state.size + Vector2.new(0, 20)
				})
			end,
		}),
		moveLeft = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(0.5, -100, 0, 50),
			AnchorPoint = Vector2.new(1, 0),
			Text = "<",
			[Roact.Event.Activated] = function()
				self:setState({
					size = self.state.size + Vector2.new(-20, 0)
				})
			end,
		}),
		moveRight = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 50, 0, 50),
			Position = UDim2.new(0.5, 0, 0, 50),
			AnchorPoint = Vector2.new(1, 0),
			Text = ">",
			[Roact.Event.Activated] = function()
				self:setState({
					size = self.state.size + Vector2.new(20, 0)
				})
			end,
		}),
	})
end

return Story