local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local HeaderBar = require(App.Bar.HeaderBarV2)
local Images = require(App.ImageSet.Images)
local IconSize = require(App.ImageSet.Enum.IconSize)
local IconButton = require(App.Button.IconButton)
local TextButton = require(App.Button.TextButton)

local Core = Packages.UIBlox.Core
local ImageSetComponent = require(Core.ImageSet.ImageSetComponent)

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

local function createStory(story, width)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(width, 45)
	}, {
		headerBar = story(),
	})
end

return {
		stories = {
			BarDemo700 = createStory(BarDemo, 700),
			BarDemo361 = createStory(BarDemo, 361),
			BarDemo300 = createStory(BarDemo, 300),
			BarWithTextButtonsDemo700 = createStory(BarWithTextButtonsDemo, 700),
			BarWithTextButtonsDemo361 = createStory(BarWithTextButtonsDemo, 361),
			BarWithTextButtonsDemo300 = createStory(BarWithTextButtonsDemo, 300),
			FrameHeaderBarWithSearchBoxForPhone = createStory(HeaderBarWithSearchBox, 450),
			FrameHeaderBarWithOnlySearchBoxForPhone = createStory(HeaderBarWithOnlySearchBox, 450),
			FrameHeaderBarWithRootTitleForPhone = createStory(HeaderBarWithRootTitle, 450),
			FrameHeaderBarWithRootTitleAndSearchBoxForTablet = createStory(
				HeaderBarWithRootTitleAndSearchBoxForTablet, 950),
			FrameHeaderBarWithBackButtonAndSearchBoxForTablet = createStory(
				HeaderBarWithBackButtonAndSearchBoxForTablet, 950),
	}
}