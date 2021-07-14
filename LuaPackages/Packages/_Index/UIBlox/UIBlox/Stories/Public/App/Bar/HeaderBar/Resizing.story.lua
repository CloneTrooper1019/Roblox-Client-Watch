local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local ResizingFrame = require(Packages.StoryComponents.ResizingFrame)

local App = Packages.UIBlox.App
local HeaderBar = require(App.Bar.HeaderBar)
local TextButton = require(App.Button.TextButton)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

return {
	name = "Header Bar: Resizing",
	summary =
		"Page margins are either 12pt, 24pt, or 48pt, " ..
		"depending on container width. " ..
		"There should be 12pt padding in between icon buttons. " ..
		"Interact with the red rulers to resize the demonstration.",
	stories = {
		CommonWithIcon = {
			name = "Common Header Bar with Icon Buttons",
			story = Roact.createElement(ResizingFrame, {
				startingWidth = 360,
				startingHeight = 80,
				horizontalRulers = { 320, 360, 540, 680 },
				LayoutOrder = 2,
			}, {
				headerBarDemo = Roact.createElement(HeaderBar, {
					title = "Title Case",
					renderLeft = function()
						return Roact.createFragment({
							button1 = Roact.createElement(IconButton, {
								size = UDim2.new(),
								icon = Images["icons/placeholder/placeholderOn"],
							}),
						})
					end,
					renderRight = function()
						return Roact.createFragment({
							button1 = Roact.createElement(IconButton, {
								size = UDim2.new(),
								icon = Images["icons/placeholder/placeholderOn"],
							}),
							button2 = Roact.createElement(IconButton, {
								size = UDim2.new(),
								icon = Images["icons/placeholder/placeholderOn"],
							}),
							button3 = Roact.createElement(IconButton, {
								size = UDim2.new(),
								icon = Images["icons/placeholder/placeholderOn"],
							}),
						})
					end
				}),
			}),
		},
		CommonWithText = {
			name = "Common Header Bar with Text Buttons",
			story = Roact.createElement(ResizingFrame, {
				startingWidth = 360,
				startingHeight = 80,
				horizontalRulers = { 320, 360, 540, 680 },
				LayoutOrder = 4,
			}, {
				headerBarDemo = Roact.createElement(HeaderBar, {
					title = "Title Case",
					renderLeft = function()
						return Roact.createFragment({
							button1 = Roact.createElement(TextButton, {
								text = "Action 1",
							}),
						})
					end,
					renderRight = function()
						return Roact.createFragment({
							button1 = Roact.createElement(TextButton, {
								text = "Action 2",
							}),
						})
					end
				}),
			}),
		}
	}
}
