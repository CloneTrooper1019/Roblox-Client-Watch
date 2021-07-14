local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local RootHeaderBar = require(App.Bar.HeaderBar)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

local function RootHeaderBarDemo(props)
	local barHeight = 64

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(375, barHeight),
		LayoutOrder = props.LayoutOrder,
	}, {
		demo = Roact.createElement(RootHeaderBar, {
			title = props.title,
			barHeight = barHeight,
			renderRight = function()
				return Roact.createFragment({
					search = Roact.createElement(IconButton, {
						icon = Images["icons/common/search"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 1,
					}),
					robux = Roact.createElement(IconButton, {
						icon = Images["icons/common/goldrobux"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 2,
					}),
					notification = Roact.createElement(IconButton, {
						icon = Images["icons/common/notificationOff"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 3,
					}),
				})
			end,
		}),
	})
end

return {
	name = "Root Header Bar: Truncation",
	summary = table.concat({
		"If the Root Header text string is too long, text will shrink until it fits.",
		"Text will truncate once text size is 24pt.",
	}, "\n\n"),
	stories = {
		header = Roact.createElement(RootHeaderBarDemo, {
			title = "Header",
			LayoutOrder = 1,
		}),
		longHeader = Roact.createElement(RootHeaderBarDemo, {
			title = "A Long Header",
			LayoutOrder = 2,
		}),
		longerHeader = Roact.createElement(RootHeaderBarDemo, {
			title = "A Longer Header",
			LayoutOrder = 3,
		}),
	}
}
