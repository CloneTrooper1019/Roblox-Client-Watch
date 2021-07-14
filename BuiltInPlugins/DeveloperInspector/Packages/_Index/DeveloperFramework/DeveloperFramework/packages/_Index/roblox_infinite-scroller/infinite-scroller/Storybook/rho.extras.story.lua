local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Story = Roact.PureComponent:extend("Rhodium Story - extra props test")

local smallScroll = Roact.PureComponent:extend("smallScroll")
function smallScroll:render()
	return Roact.createElement(Scroller, Cryo.Dictionary.join({
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Size = UDim2.new(0, 50, 0, 50),
		padding = UDim.new(),
		focusIndex = 6,
		anchorLocation = UDim.new(0.5, 0),
		loadingBuffer = 2,
		mountingBuffer = 99,
		estimatedItemSize = 10,
	}, self.props))
end

function Story:init()
	self.state = {
		items = {},
		store = {},
	}
	for i = 1, 11 do
		self.state.items[i] = i
		self.state.store[i] = (i == 6
			and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(0, i*23, i*23))
	end

	self.renderItem = function(item)
		return Roact.createElement("Frame", {
			Size = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = self.state.store[item],
		}, {
			["INDEX" .. tostring(item)] = Roact.createElement("Frame"),
		})
	end
end

function Story:render()
	return Roact.createElement("Frame", {}, {
		scroller = Roact.createElement(smallScroll, Cryo.Dictionary.join({
			itemList = self.state.items,
			renderItem = self.renderItem,
			extraProps = {self.state.store},
		}, self.props, {newColor = Cryo.None})),
		change = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 100, 0, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Text = "X",
			[Roact.Event.Activated] = function()
				local newColor = self.props.newColor
				if not newColor then
					newColor = Color3.fromRGB(
						math.random(0, 255),
						math.random(0, 255),
						math.random(0, 255)
					)
					print("Changing color to ", newColor)
				end

				local store = {}
				for i = 1, 11 do
					store[i] = newColor
				end
				self:setState({store = store})
			end,
		}),
	})
end

return Story
