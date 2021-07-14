local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local IconSize = require(App.ImageSet.Enum.IconSize)
local Images = require(App.ImageSet.Images)
local RootHeaderBar = require(App.Bar.HeaderBarV2)
local IconButton = require(App.Button.IconButton)

local Core = Packages.UIBlox.Core
local ImageSetComponent = require(Core.ImageSet.ImageSetComponent)

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

return {
	stories = {
		Phone = RootHeaderBarForPhone,
		SearchBox = RootHeaderBarWithSearchBox,
	}
}