-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Bar\HeaderBar.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local Bar = script.Parent.Parent
local App = Bar.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local Images = require(App.ImageSet.Images)
local IconSize = require(App.ImageSet.Enum.IconSize)
local HeaderBar = require(Bar.HeaderBarV2)
local IconButton = require(UIBlox.App.Button.IconButton)
local TextButton = require(UIBlox.App.Button.TextButton)
local ImageSetComponent = require(UIBlox.Core.ImageSet.ImageSetComponent)

local renderRightIcons = function()
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
end

local function BarDemo()
	return Roact.createElement(HeaderBar, {
		title = string.rep("Header Bar Story", 1),
		renderLeft = HeaderBar.renderLeft.backButton(function()
			print("navProps.navigation.pop()")
		end),
		renderRight = renderRightIcons,
	})
end

local function BarWithTextButtonsDemo()
	return Roact.createElement(HeaderBar, {
		title = string.rep("Header Bar Story", 1),
		renderLeft = function()
			return Roact.createFragment({
				search = Roact.createElement(TextButton, {
					text = "Action 1",
					onActivated = function()
						print("Opening Search!")
					end,
					layoutOrder = 1,
				}),
			})
		end,
		renderRight = function()
			return Roact.createFragment({
				search = Roact.createElement(TextButton, {
					text = "Action 2",
					onActivated = function()
						print("Opening Search!")
					end,
					layoutOrder = 1,
				}),
			})
		end,
	})
end

local function HeaderBarWithSearchBox()
	return Roact.createElement(HeaderBar, {
		title = "",
		renderLeft = HeaderBar.renderLeft.backButton(function()
			print("navProps.navigation.pop()")
		end),
		renderCenter = function()
			return Roact.createFragment({
				searchBoxMock = Roact.createElement(ImageSetComponent.Label, {
					Image = Images["component_assets/circle_17_stroke_1"],
					SliceCenter = Rect.new(8, 8, 9, 9),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
				}),
			})
		end,
	})
end

local function HeaderBarWithOnlySearchBox()
	return Roact.createElement(HeaderBar, {
		title = "",
		renderLeft = nil,
		renderCenter = function()
			return Roact.createFragment({
				searchBoxMock = Roact.createElement(ImageSetComponent.Label, {
					Image = Images["component_assets/circle_17_stroke_1"],
					SliceCenter = Rect.new(8, 8, 9, 9),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
				}),
			})
		end,
	})
end

local function HeaderBarWithRootTitle()
	return Roact.createElement(HeaderBar, {
		title = "Avatar",
		renderRight = renderRightIcons,
	})
end

local function HeaderBarWithRootTitleAndSearchBoxForTablet()
	return Roact.createElement(HeaderBar, {
		title = "Discover",
		renderCenter = function()
			return Roact.createFragment({
				searchBoxMock = Roact.createElement(ImageSetComponent.Label, {
					Image = Images["component_assets/circle_17_stroke_1"],
					SliceCenter = Rect.new(8, 8, 9, 9),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.new(0, 250, 0, 36),
					BackgroundTransparency = 1,
				}),
			})
		end,
		renderRight = renderRightIcons,
	})
end

local function HeaderBarWithBackButtonAndSearchBoxForTablet()
	return Roact.createElement(HeaderBar, {
		title = "",
		renderLeft = HeaderBar.renderLeft.backButton(function()
			print("navProps.navigation.pop()")
		end),
		renderCenter = function()
			return Roact.createFragment({
				searchBoxMock = Roact.createElement(ImageSetComponent.Label, {
					Image = Images["component_assets/circle_17_stroke_1"],
					SliceCenter = Rect.new(8, 8, 9, 9),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.new(0, 250, 0, 36),
					BackgroundTransparency = 1,
				}),
			})
		end,
		renderRight = renderRightIcons,
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story =	Roact.createElement(StoryItem, {
			backgroundColor3 = Color3.fromRGB(177, 177, 177),
			size = UDim2.fromScale(1, 1),
			title = "HeaderBar",
			subTitle = "App.Bar.HeaderBar",
		}, {
			layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 15),
			}),
			frame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(700, 45),
				LayoutOrder = 1,
			}, {
				headerBar = Roact.createElement(BarDemo)
			}),
			frame2 = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(361, 45),
				LayoutOrder = 2,
			}, {
				headerBar = Roact.createElement(BarDemo)
			}),
			frame3 = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(300, 45),
				LayoutOrder = 3,
			}, {
				headerBar = Roact.createElement(BarDemo)
			}),
			frame4 = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(700, 45),
				LayoutOrder = 4,
			}, {
				headerBar = Roact.createElement(BarWithTextButtonsDemo)
			}),
			frame5 = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(361, 45),
				LayoutOrder = 5,
			}, {
				headerBar = Roact.createElement(BarWithTextButtonsDemo)
			}),
			frame6 = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(300, 45),
				LayoutOrder = 6,
			}, {
				headerBar = Roact.createElement(BarWithTextButtonsDemo)
			}),
			frameHeaderBarWithSearchBoxForPhone = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(450, 45),
				LayoutOrder = 7,
			}, {
				headerBar = Roact.createElement(HeaderBarWithSearchBox)
			}),
			frameHeaderBarWithOnlySearchBoxForPhone = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(450, 45),
				LayoutOrder = 8,
			}, {
				headerBar = Roact.createElement(HeaderBarWithOnlySearchBox)
			}),
			frameHeaderBarWithRootTitleForPhone = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(450, 45),
				LayoutOrder = 9,
			}, {
				headerBar = Roact.createElement(HeaderBarWithRootTitle)
			}),
			frameHeaderBarWithRootTitleAndSearchBoxForTablet = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(950, 45),
				LayoutOrder = 10,
			}, {
				headerBar = Roact.createElement(HeaderBarWithRootTitleAndSearchBoxForTablet)
			}),
			frameHeaderBarWithBackButtonAndSearchBoxForTablet = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(950, 45),
				LayoutOrder = 11,
			}, {
				headerBar = Roact.createElement(HeaderBarWithBackButtonAndSearchBoxForTablet)
			}),
		}),
	}), target, "HeaderBar")
	return function()
		Roact.unmount(handle)
	end
end
