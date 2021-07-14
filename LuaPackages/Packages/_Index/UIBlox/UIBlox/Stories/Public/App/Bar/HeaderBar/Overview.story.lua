local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local HeaderBar = require(App.Bar.HeaderBar)
local TextButton = require(App.Button.TextButton)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

local function HeaderBarDemo(props)
	local barHeight = 45
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 414, 0, barHeight),
		LayoutOrder = props.LayoutOrder,
	}, {
		demo = Roact.createElement(HeaderBar, {
			barHeight = barHeight,
			title = "Title Case",
			renderLeft = props.renderLeft,
			renderRight = props.renderRight,
		}),
	})
end

return {
	name = "Header Bar: Overview",
	summary = "The Header Bar is used on almost every page that doesn't have a Root Header Bar",
	stories = {
		WithIconButtons = {
			name = "Common Header Bar with Icon Buttons",
			summary = "It may have 1 icon on the left and up to 3 icons on the right",
			story = Roact.createElement(HeaderBarDemo, {
					renderLeft = function()
						return Roact.createFragment({
							button1 = Roact.createElement(IconButton, {
								size = UDim2.new(),
								icon = Images["icons/placeholder/placeholderOn"],
							})
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
					end,
					LayoutOrder = 2,
				}),
		},
		WithTextButtons = {
			name = "Common Header Bar with Text Buttons",
			summary = "It cannot have more than one text button on either side",
			story = Roact.createElement(HeaderBarDemo, {
				renderLeft = function()
					return Roact.createFragment({
						button1 = Roact.createElement(TextButton, {
							text = "Action 1",
						})
					})
				end,
				renderRight = function()
					return Roact.createFragment({
						button1 = Roact.createElement(TextButton, {
							text = "Action 2",
						})
					})
				end,
				LayoutOrder = 4,
			}),
		}
	}
}
