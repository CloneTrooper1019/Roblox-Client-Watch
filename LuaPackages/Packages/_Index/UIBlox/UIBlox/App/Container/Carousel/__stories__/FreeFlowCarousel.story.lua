-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Container\FreeFlowCarousel.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local Carousel = script.Parent.Parent
local Container = Carousel.Parent
local App = Container.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)
local FreeFlowCarousel = require(Carousel.FreeFlowCarousel)

return function(target)

	local items = {}
	for i = 1, 10 do
		table.insert(items, {
			Text = i,
			Size = UDim2.fromOffset(100, 100),
		})
	end

	local renderItem = function(props)
		return Roact.createElement("TextLabel", props)
	end

	local loadNext = function()
		for i = 1, 10 do
			table.insert(items, {
				Text = i,
				Size = UDim2.fromOffset(100, 100),
			})
		end
	end

	local element = Roact.createElement(StoryItem, {
			size = UDim2.fromScale(1, 1),
			title = "Carousel",
			subTitle = "App.Container.Carousel.FreeFlowCarousel",
		}, {
			Roact.createElement(FreeFlowCarousel, {
				identifier = function(item)
					return tostring(item)
				end,
				headerText = "test header",
				onSeeAll = function()end,
				itemList = items,
				renderItem = renderItem,
				itemSize = Vector2.new(100, 100),
				itemPadding = 12,
				carouselMargin = 36,
				layoutOrder = 1,
				loadNext = loadNext,
			})
		})

	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story =	element
	}), target, "Carousel")
	return function()
		Roact.unmount(handle)
	end
end
