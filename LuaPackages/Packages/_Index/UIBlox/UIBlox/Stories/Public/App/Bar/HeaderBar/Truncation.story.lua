local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local HeaderBar = require(App.Bar.HeaderBar)
local TextButton = require(App.Button.TextButton)

local function HeaderBarDemo(props)
	local barHeight = 48

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(400, barHeight),
		LayoutOrder = props.LayoutOrder,
	}, {
		demo = Roact.createElement(HeaderBar, {
			title = props.title,
			barHeight = barHeight,
			renderLeft = function()
				return Roact.createFragment({
					textButton = Roact.createElement(TextButton, {
						text = props.leftActionText,
					}),
				})
			end,
			renderRight = function()
				return Roact.createFragment({
					textButton = Roact.createElement(TextButton, {
						text = props.rightActionText,
					}),
				})
			end,
		}),
	})
end

return {
	name = "Header Bar: Truncation",
	summary = table.concat({
		"If the Header text buttons are too long, the Header text is pushed to the left or right.",
		"Otherwise, the header text is truncated with an ellipsis.",
	}, "\n\n"),
	stories = {
		demo1 = Roact.createElement(HeaderBarDemo, {
			title = "Header",
			leftActionText = "Action 1",
			rightActionText = "Action 2",
			LayoutOrder = 1,
		}),
		demo2 = Roact.createElement(HeaderBarDemo, {
			title = "Header",
			leftActionText = "Long Left Action",
			rightActionText = "Action 2",
			LayoutOrder = 2,
		}),
		demo3 = Roact.createElement(HeaderBarDemo, {
			title = "Header",
			leftActionText = "Action 1",
			rightActionText = "Long Right Action",
			LayoutOrder = 3,
		}),
		demo4 = Roact.createElement(HeaderBarDemo, {
			title = "Long Header",
			leftActionText = "Long Action",
			rightActionText = "Long Action",
			LayoutOrder = 4,
		}),
	}
}
