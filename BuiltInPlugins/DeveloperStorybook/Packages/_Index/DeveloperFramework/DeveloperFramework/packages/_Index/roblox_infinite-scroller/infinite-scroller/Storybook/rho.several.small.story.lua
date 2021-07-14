local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Rhodium Story - enough small items to fill the view")

function Story:render()
	return Roact.createElement(Scroller, Cryo.Dictionary.join({
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Size = UDim2.new(0, 50, 0, 50),
		padding = UDim.new(),
		itemList = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
		focusIndex = 6,
		anchorLocation = UDim.new(0.5, 0),
		loadingBuffer = 2,
		mountingBuffer = 99,
		estimatedItemSize = 10,
		renderItem = function(item, _)
			return Roact.createElement("Frame", {
				Size = UDim2.new(0, 10, 0, 10),
				BackgroundColor3 = item == 6
					and Color3.fromRGB(255, 255, 255)
					or Color3.fromRGB(0, item*23, item*23),
			}, {
				["INDEX" .. tostring(item)] = Roact.createElement("Frame"),
			})
		end,
	}, self.props))
end

return Story