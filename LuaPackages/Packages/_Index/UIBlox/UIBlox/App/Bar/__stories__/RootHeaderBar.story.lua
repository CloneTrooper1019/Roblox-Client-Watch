-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Bar\RootHeaderBar.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local Bar = script.Parent.Parent
local App = Bar.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local IconSize = require(App.ImageSet.Enum.IconSize)
local Images = require(App.ImageSet.Images)
local RootHeaderBar = require(Bar.HeaderBarV2)
local IconButton = require(App.Button.IconButton)
local ImageSetComponent = require(UIBlox.Core.ImageSet.ImageSetComponent)

local function RootHeaderBarWithSearchBox()
	return Roact.createElement(RootHeaderBar, {
		title = "Hello",
		renderCenter = function()
			return Roact.createFragment({
				searchBoxMock = Roact.createElement(ImageSetComponent.Label, {
					Image = Images["component_assets/circle_17_stroke_1"],
					SliceCenter = Rect.new(8, 8, 9, 9),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.fromOffset(200, 36),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
				}),
			})
		end,
		renderRight = function()
			return Roact.createFragment({
				search = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/search"],
					onActivated = function()
						print("Opening Search!")
					end,
					layoutOrder = 1,
				}),
				premium = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/goldrobux"],
					onActivated = function()
						print("Oooh Shiny!")
					end,
					layoutOrder = 2,
				}),
				alert = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/notificationOn"],
					onActivated = function()
						print("Alert!")
					end,
					layoutOrder = 3,
				}),
			})
		end,
	})
end

local function RootHeaderBarForPhone()
	return Roact.createElement(RootHeaderBar, {
		title = "Hello",
		renderRight = function()
			return Roact.createFragment({
				search = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/search"],
					onActivated = function()
						print("Opening Search!")
					end,
					layoutOrder = 1,
				}),
				premium = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/goldrobux"],
					onActivated = function()
						print("Oooh Shiny!")
					end,
					layoutOrder = 2,
				}),
				alert = Roact.createElement(IconButton, {
					iconSize = IconSize.Medium,
					icon = Images["icons/common/notificationOn"],
					onActivated = function()
						print("Alert!")
					end,
					layoutOrder = 3,
				}),
			})
		end,
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 1, 0),
				title = "RootHeaderBar",
				subTitle = "App.Bar.RootHeaderBar",
			}, {
				layout = Roact.createElement("UIListLayout"),
				frame1 = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(800, 45),
				}, {
					headerBar = Roact.createElement(RootHeaderBarWithSearchBox)
				}),
				frame2 = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(350, 45),
				}, {
					headerBar = Roact.createElement(RootHeaderBarForPhone)
				}),
			})
	}), target, "HeaderBar")
	return function()
		Roact.unmount(handle)
	end
end
