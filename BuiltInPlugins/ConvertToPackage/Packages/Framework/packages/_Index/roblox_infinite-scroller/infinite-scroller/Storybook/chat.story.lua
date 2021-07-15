local HttpService = game:GetService("HttpService")

local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Thing = require(script.Parent.ResizingThing)

local Box = function(props)
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40),
		Text = props.text,
	})
end

local Story = Roact.PureComponent:extend("Story")

function Story:init()
	self.state = {
		items = {},
		lock = 0,
		index = 1,
		size = Vector2.new(400, -100),
	}
end

function Story:render()
	return Roact.createFragment({
		scroller = Roact.createElement(Scroller, {
			BackgroundColor3 = Color3.fromRGB(56, 19, 18),
			Size = UDim2.new(0, self.state.size.X, 1, self.state.size.Y),
			Position = UDim2.new(0, 50, 0, 50),
			ScrollBarThickness = 8,
			padding = UDim.new(0, 5),
			orientation = Scroller.Orientation.Down,
			itemList = self.state.items,
			focusLock = self.state.lock,
			focusIndex = self.state.index,
			anchorLocation = UDim.new(0, 0),
			estimatedItemSize = 40,
			dragBuffer = 0,
			extraProps = self.state.items,
			identifier = function(item)
				return item.guid
			end,
			renderItem = function(item, _)
				return Roact.createElement(Box, item)
			end,
			onScrollUpdate = function(data)
				self.indexData = data
			end
		}),
		textbox = Roact.createElement("TextBox", {
			Size = UDim2.new(0, 100, 0, 50),
			Position = UDim2.new(1, -100, 0, 0),
			[Roact.Event.FocusLost] = function(rbx, entered)
				if entered and rbx.Text ~= "" then
					local newItem = {
						text = rbx.Text,
						guid = HttpService:GenerateGUID(false),
					}

					local newState
					if self.state.items then
						newState = { items = Cryo.List.join(self.state.items, { newItem })}

						if self.indexData and self.indexData.anchorIndex == #self.state.items then
							newState.lock = self.state.lock + 1
							newState.index = #newState.items
						end
					else
						newState = {
							items = { newItem },
							index = 1,
							lock = 1,
						}
					end

					rbx.Text = ""
					self:setState(newState)
				end
			end
		}),
	})
end

return Story