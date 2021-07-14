-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Grid.story.lua`

local GridRoot = script.Parent.Parent
local AppRoot = GridRoot.Parent
local UIBloxRoot = AppRoot.Parent
local Packages = UIBloxRoot.Parent
local Roact = require(Packages.Roact)
local UIBloxConfig = require(UIBloxRoot.UIBloxConfig)
local RoactGamepad = require(Packages.RoactGamepad)

local DefaultMetricsGridView = require(GridRoot.DefaultMetricsGridView)
local GridMetrics = require(GridRoot.GridMetrics)

local InputManager = require(Packages.StoryComponents.InputManager)

local DemoComponent = Roact.PureComponent:extend("DemoComponent")

function DemoComponent:init()
	self.scrollingRef = Roact.createRef()

	self.state = {
		windowSize = Vector2.new(0, 0),
		metrics = GridMetrics.getSmallMetrics,
	}

	if UIBloxConfig.enableExperimentalGamepadSupport then
		self.focusController = RoactGamepad.createFocusController()
	end
end

function DemoComponent:updateWindowSize()
	self:setState({
		windowSize = self.scrollingRef.current.AbsoluteWindowSize,
	})
end

function DemoComponent:render()
	local items = {}

	for i = 1, 100 do
		table.insert(items, i)
	end

	local metrics = {
		{
			name = "Small",
			getter = GridMetrics.getSmallMetrics,
		},
		{
			name = "Medium",
			getter = GridMetrics.getMediumMetrics,
		},
		{
			name = "Large",
			getter = GridMetrics.getLargeMetrics,
		},
	}

	local selectorChildren = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		})
	}

	for index, item in ipairs(metrics) do
		selectorChildren[item.name] = Roact.createElement("TextButton", {
			Size = UDim2.new(1 / #metrics, 0, 1, 0),
			Text = item.name,
			LayoutOrder = index,
			[Roact.Event.Activated] = function()
				self:setState({
					metrics = GridMetrics["get" .. item.name .. "Metrics"],
				})
			end,
		})
	end

	return Roact.createElement(UIBloxConfig.enableExperimentalGamepadSupport and
		RoactGamepad.Focusable.Frame or "Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,

		focusController = UIBloxConfig.enableExperimentalGamepadSupport and self.focusController or nil,
	}, {
		InputManager = UIBloxConfig.enableExperimentalGamepadSupport and Roact.createElement(InputManager, {
			focusController = self.focusController,
		}),
		MetricsSelector = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		}, selectorChildren),
		GridScroller = Roact.createElement("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			[Roact.Ref] = self.scrollingRef,
			[Roact.Change.AbsoluteSize] = function()
				wait(0)
				self:updateWindowSize()
			end,
		}, {
			GridView = Roact.createElement(DefaultMetricsGridView, {
				renderItem = function(i)
					return Roact.createElement("TextLabel", {
						Text = i,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 1, 0),
					})
				end,
				getItemHeight = function(width)
					return width
				end,
				getItemMetrics = self.state.metrics,
				windowHeight = self.state.windowSize.Y,
				itemPadding = Vector2.new(12, 12),
				items = items,

				defaultChildIndex = UIBloxConfig.enableExperimentalGamepadSupport and 1 or nil,
			})
		})
	})
end

function DemoComponent:didMount()
	self:updateWindowSize()
end

return function(target)
	local handle = Roact.mount(Roact.createElement(DemoComponent), target, "2DGrid")

	return function()
		Roact.unmount(handle)
	end
end
