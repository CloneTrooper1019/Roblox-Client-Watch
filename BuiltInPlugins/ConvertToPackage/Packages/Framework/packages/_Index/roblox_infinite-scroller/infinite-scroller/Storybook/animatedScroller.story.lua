local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Story")

function Story:init()
	self.state = {
		items = {},
		lock = 1,
	}

	for i = 1, 50 do
		table.insert(self.state.items, i)
	end

	self.focus = 1
end

function Story:render()
	return Roact.createFragment({
		Roact.createElement(Scroller, Cryo.Dictionary.join({
			BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			Size = UDim2.new(0, 165, 0, 50),
			orientation = Scroller.Orientation.Right,
			padding = UDim.new(0, 5),
			itemList = self.state.items,
			focusIndex = self.focus,
			focusLock = self.state.lock,
			anchorLocation = UDim.new(1, -15),
			loadingBuffer = 2,
			mountingBuffer = 99,
			estimatedItemSize = 10,
			dragBuffer = 120,
			animateScrolling = true,
			identifier = function(item)
				assert(item)
				return item
			end,
			renderItem = function(item, _)
				return Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 30, 0, 30),
					Text = tostring(item),
					BackgroundColor3 = Color3.fromRGB(255, item*5, (51 - item)*5),
				}, {
					["INDEX" .. tostring(item)] = Roact.createElement("Frame"),
				})
			end,
			onScrollUpdate = function(data)
				self.focus = data.anchorIndex
				self.animationActive = data.animationActive
			end,
		}, self.props)),
		Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 200, 0, 0),
			Text = "<",
			[Roact.Event.Activated] = function()
				if self.animationActive then
					return
				end
				self.focus = math.max(self.focus - 4, 1)
				self:setState({lock = self.state.lock + 1})
			end,
		}),
		Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 230, 0, 0),
			Text = ">",
			[Roact.Event.Activated] = function()
				if self.animationActive then
					return
				end
				self.focus = math.min(self.focus + 4, #self.state.items)
				self:setState({lock = self.state.lock + 1})
			end,
		}),
	})
end

return Story