local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local FreeFlowCarousel = require(App.Container.Carousel.FreeFlowCarousel)

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

return Roact.createElement(FreeFlowCarousel, {
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
