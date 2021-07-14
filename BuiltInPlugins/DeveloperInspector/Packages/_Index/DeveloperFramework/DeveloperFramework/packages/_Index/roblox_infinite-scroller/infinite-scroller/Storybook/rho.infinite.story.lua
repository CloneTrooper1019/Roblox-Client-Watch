local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Rhodium Story - infinite scroll in both directions")

function Story:init()
	self.state.items = {
		{
			token = 0,
			color = Color3.fromRGB(255, 255, 255),
		}
	}
	self.state.size = Vector2.new(50, 50)

	self.loadPrevious = function()
		local newItems = {}
		local n = self.state.items[1].token
		for i = n-10, n-1 do
			table.insert(newItems, {
				token = i,
				color = Color3.fromRGB(0, 128 - i, 128 + i),
			})
		end
		self:setState({
			items = Cryo.List.join(newItems, self.state.items)
		})
	end

	self.loadNext = function()
		local newItems = {}
		local n = self.state.items[#self.state.items].token
		for i = n+1, n+10 do
			table.insert(newItems, {
				token = i,
				color = Color3.fromRGB(0, 128 - i, 128 + i),
			})
		end
		self:setState({
			items = Cryo.List.join(self.state.items, newItems)
		})
	end
end

function Story:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		scroll = Roact.createElement(Scroller, Cryo.Dictionary.join({
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			Size = UDim2.new(0, self.state.size.X, 0, self.state.size.Y),
			padding = UDim.new(0, 3),
			itemList = self.state.items,
			loadNext = self.loadNext,
			loadPrevious = self.loadPrevious,
			focusIndex = 1,
			anchorLocation = UDim.new(0.5, 0),
			orientation = Scroller.Orientation.Up,
			estimatedItemSize = 10,
			mountingBuffer = 50,
			identifier = function(item)
				return item.token
			end,
			renderItem = function(item, _)
				assert(item.token, "Item's token is unset")
				assert(item.color, "Item's color is unset")
				return Roact.createElement("Frame", {
					Size = UDim2.new(0, 10, 0, 10),
					BackgroundColor3 = item.color,
				}, {
					["INDEX" .. tostring(item.token)] = Roact.createElement("Frame"),
				})
			end,
		}, self.props)),
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