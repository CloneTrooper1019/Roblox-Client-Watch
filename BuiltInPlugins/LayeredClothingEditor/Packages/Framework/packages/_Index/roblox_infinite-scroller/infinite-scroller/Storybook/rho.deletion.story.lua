local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Rhodium Story - item deletion test")

function Story:init()
	self.state.items = {}
	for i = -20,20 do
		table.insert(self.state.items, {id = i})
	end
end

function Story:render()
	return Roact.createElement("Frame", {
		Size=UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		scroll = Roact.createElement(Scroller, Cryo.Dictionary.join(
			{
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				Size = UDim2.new(0, 100, 0, 100),
				padding = UDim.new(),
				itemList = self.state.items,
				focusIndex = 21,
				anchorLocation = UDim.new(0.5, 0),
				loadingBuffer = 2,
				mountingBuffer = 99,
				estimatedItemSize = 10,
				identifier = function(item)
					return item.id
				end,
				renderItem = function(item, _)
					return Roact.createElement("Frame", {
						Size = UDim2.new(0, 10, 0, 10),
						BackgroundColor3 = item == 0
							and Color3.fromRGB(255, 255, 255)
							or Color3.fromRGB(0, 128 - 8*item.id, 128 + 8*item.id),
					}, {
						["INDEX" .. tostring(item.id)] = Roact.createElement("Frame"),
					})
				end,
			},
			self.props,
			{toDelete = Cryo.None}
		)),
		deletion = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 100, 0, 50),
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			Text = "Delete",
			[Roact.Event.Activated] = function()
				local nextItems
				if self.props.toDelete then
					nextItems = Cryo.List.filter(self.state.items, function(item)
						for _, v in pairs(self.props.toDelete) do
							if item.id == v then
								return false
							end
						end
						return true
					end)
				else
					local n = math.random(1, #self.state.items)
					print("Deleting index " .. tostring(n))
					nextItems = Cryo.List.removeIndex(self.state.items, n)
				end
				self:setState({
					items = nextItems
				})
			end,
		}),
	})
end

return Story