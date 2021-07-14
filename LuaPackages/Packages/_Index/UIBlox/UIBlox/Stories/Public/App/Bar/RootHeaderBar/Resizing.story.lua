local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local ResizingFrame = require(Packages.StoryComponents.ResizingFrame)

local App = Packages.UIBlox.App
local RootHeaderBar = require(App.Bar.HeaderBar)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

return {
	name = "Root Header Bar: Resizing",
	summary =
		"Page margins are either 12pt, 24pt, or 48pt, depending on container width.\n\n" ..
		"There should be 0pt padding in between icon buttons.\n\n" ..
		"Special Case: On landscape, if the screen height is 600pt or less, " ..
		"the Common Header Bar is used instead of the Root Header Bar.\n\n" ..
		"Interact with the red rulers to resize the demonstration.",
	story = Roact.createElement(ResizingFrame, {
		startingWidth = 360,
		startingHeight = 250,
		horizontalRulers = { 350, 360, 540, 680 },
	}, {
		rootHeaderBarDemo = Roact.createElement(RootHeaderBar, {
			title = "Title Case",
			isRootTitle = true,
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
	})
}
