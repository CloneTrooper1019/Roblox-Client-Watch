local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Rhodium Story - a few large items")

function Story:render()
	return Roact.createElement(Scroller, Cryo.Dictionary.join({
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Size = UDim2.new(0, 50, 0, 50),
		padding = UDim.new(),
		itemList = {1, 2, 3, 4, 5, 6, 7},
		focusIndex = 4,
		anchorLocation = UDim.new(0.5, 0),
		loadingBuffer = 2,
		mountingBuffer = 49,
		renderItem = function(item, _)
			return Roact.createElement("Frame", {
				Size = UDim2.new(0, 50, 0, 50),
				BackgroundColor3 = Color3.fromRGB(item*30, item*30, item*30),
			}, {
				["INDEX" .. tostring(item)] = Roact.createElement("Frame"),
			})
		end,
	}, self.props))
end

return Story