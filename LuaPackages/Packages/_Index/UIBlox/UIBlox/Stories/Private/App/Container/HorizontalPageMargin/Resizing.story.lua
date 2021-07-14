local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local ResizingFrame = require(Packages.StoryComponents.ResizingFrame)

local App = Packages.UIBlox.App
local HorizontalPageMargin = require(App.Container.HorizontalPageMargin)

return {
	name = "HorizontalPageMargin: Resizing",
	summary =
		"Page margins are either 12pt, 24pt, or 48pt, depending on " ..
		"container width. Interact with the red rulers to resize the" ..
		"demonstration.",
	stories = {
		resizeDemo1 = Roact.createElement(ResizingFrame, {
			startingWidth = 360,
			startingHeight = 80,
			horizontalRulers = { 360, 540, 680 },
			LayoutOrder = 2,
		}, {
			demo = Roact.createElement(HorizontalPageMargin, {
				backgroundColor3 = Color3.fromRGB(155, 10, 155),
			}, {
				text = Roact.createElement("TextLabel", {
					Text = "text",
					Size = UDim2.fromScale(1, 1),
				}),
			}),
		}),
		resizeDemo2 = Roact.createElement(ResizingFrame, {
			startingWidth = 360,
			startingHeight = 80,
			horizontalRulers = { 360, 540, 680 },
			LayoutOrder = 4,
		}, {
			demo = Roact.createElement(HorizontalPageMargin, {
				backgroundColor3 = Color3.fromRGB(155, 10, 155),
			}, {
				text = Roact.createElement("TextLabel", {
					Text = "text",
					Size = UDim2.fromScale(1, 1),
				}),
			}),
		}),
	}
}
