local InfiniteScroller = script:FindFirstAncestor("infinite-scroller")
local Root = InfiniteScroller.Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local Scroller = require(InfiniteScroller).Scroller

local Thing = require(script.Parent.ResizingThing)

local Story = Roact.PureComponent:extend("Story")

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
			loadNext = self.loadNext,
			loadPrevious = self.loadPrevious,
			focusLock = self.state.lock,
			focusIndex = self.state.index,
			anchorLocation = UDim.new(0, 0),
			estimatedItemSize = 40,
			identifier = function(item) return item.token end,
			renderItem = function(item, _)
				return Roact.createElement(Thing, item)
			end,
			onScrollUpdate = function(data)
				self.indexData = data
			end
		}),
		refresh = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 110, 0, 30),
			Position = UDim2.new(1, -50, 0, 50),
			AnchorPoint = Vector2.new(1, 0),
			Text = "Refresh",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.clickRefresh,
		}),
		up = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -90, 0, 90),
			AnchorPoint = Vector2.new(1, 0),
			Text = "^",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.clickUp,
		}),
		down = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -90, 0, 170),
			AnchorPoint = Vector2.new(1, 0),
			Text = "v",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.clickDown,
		}),
		left = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -130, 0, 130),
			AnchorPoint = Vector2.new(1, 0),
			Text = "<",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.clickLeft,
		}),
		right = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -50, 0, 130),
			AnchorPoint = Vector2.new(1, 0),
			Text = ">",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.clickRight,
		}),
		skipUp = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 60, 0, 30),
			Position = UDim2.new(1, -90, 0, 220),
			AnchorPoint = Vector2.new(1, 0),
			Text = "SkipUp",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.skipUp,
		}),
		skipDown = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 60, 0, 30),
			Position = UDim2.new(1, -90, 0, 270),
			AnchorPoint = Vector2.new(1, 0),
			Text = "SkipDown",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			[Roact.Event.Activated] = self.skipDown,
		}),
		SkipAmount = Roact.createElement("TextBox", {
			Size = UDim2.new(0, 60, 0, 30),
			Position = UDim2.new(1, 0, 0, 270),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "SkipAmt",
			PlaceholderText = "Skip",
			ClearTextOnFocus = true,
			[Roact.Change.Text] = self.onChangeText,
		}),
	})
end

local function generate(token)
	if token == 0 then
		return {color=Color3.fromRGB(255, 255, 255), width=50, token=0}
	end
	return {color=Color3.fromRGB(128-token, 255, 128+token), width=50+40*math.sin(token/5), token=token}
end

function Story:init()
	local items = {}
	for i = -100,100 do table.insert(items, generate(i)) end
	self.state = {
		lock = 1,
		index = 101,
		skipAmount = 1,
		size = Vector2.new(200, -100),
		items = items,
	}
	self.indexData = {
		anchorIndex = 101,
	}

	self.loadNext = function()
		self:setState({
			items = Cryo.List.join(self.state.items, {generate(self.state.items[#self.state.items].token + 1)}),
		})
	end

	self.loadPrevious = function()
		self:setState({
			items = Cryo.List.join({generate(self.state.items[1].token - 1)}, self.state.items),
		})
	end

	self.clickRefresh = function()
		print("Recentering")
		self:setState({
			lock = self.state.lock + 1,
		})
	end

	self.clickUp = function()
		print("Moving up")
		self:setState({
			size = self.state.size + Vector2.new(0, -20),
		})
	end

	self.clickDown = function()
		print("Moving down")
		self:setState({
			size = self.state.size + Vector2.new(0, 20),
		})
	end

	self.clickLeft = function()
		print("Moving left")
		self:setState({
			size = self.state.size + Vector2.new(-20, 0),
		})
	end

	self.clickRight = function()
		print("Moving right")
		self:setState({
			size = self.state.size + Vector2.new(20, 0),
		})
	end

	self.skipUp = function()
		local newIndex = self.indexData.anchorIndex + self.state.skipAmount
		print("Skipping up to index:", newIndex)
		self:setState({
			lock = self.state.lock + 1,
			index = newIndex,
		})
	end

	self.skipDown = function()
		local newIndex = self.indexData.anchorIndex - self.state.skipAmount
		print("Skipping down to index:", newIndex)
		self:setState({
			lock = self.state.lock + 1,
			index = newIndex,
		})
	end

	self.onChangeText = function(rbx)
		local skipAmount = tonumber(rbx.Text)
		print("skipAmount:", skipAmount)
		if skipAmount then
			self:setState({
				skipAmount = skipAmount,
			})
		else
			rbx.Text = self.state.skipAmount
		end
	end
end

return Story