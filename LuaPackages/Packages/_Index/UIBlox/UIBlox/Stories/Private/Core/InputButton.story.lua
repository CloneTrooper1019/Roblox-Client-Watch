local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)

local Core = Packages.UIBlox.Core
local withStyle = require(Core.Style.withStyle)
local InputButton = require(Core.InputButton.InputButton)

local InputButtonStory = Roact.PureComponent:extend("InputButtonStory")

function InputButtonStory:render()
	local props = self.props

	return withStyle(function(style)
		local theme = style.Theme.SystemPrimaryDefault
		return Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			-- BackgroundTransparency = 1,
		}, {
			Roact.createElement(InputButton, {
				text = props.text,
				size = props.size,
				image = Images["component_assets/circle_24_stroke_1"],
				imageColor = Color3.fromRGB(0, 255, 0),
				fillImage = Images["component_assets/circle_16"],
				fillImageSize = UDim2.new(10, 10),
				fillImageColor = Color3.fromRGB(111, 222, 111),
				selectedColor = Color3.fromRGB(255, 0, 0),
				textColor = theme.Color,
				transparency = theme.Transparency,
				onActivated = function(value) print(value) end,
			})
		})
	end)
end

return {
	stories = {
		oneLineButton = {
			name = "One Line Button",
			story = Roact.createElement(InputButtonStory, {
				text = "Text",
				size = UDim2.new(0, 130, 0, 40),
			})
		},
		twoLineButton = {
			name = "Two Line Button",
			story = Roact.createElement(InputButtonStory, {
				text = "Two lines of text",
				size = UDim2.new(0, 130, 0, 40),
			})
		},
		threeLineButton = {
			name = "Three Line Button",
			story = Roact.createElement(InputButtonStory, {
				text = "This has three lines of text",
				size = UDim2.new(0, 130, 0, 60),
			})
		},
		tenLineButton = {
			name = "Ten Line Button",
			story = Roact.createElement(InputButtonStory, {
				text = "An example of the unreasonable amount of text wrapping we could do. This is 10 lines",
				size = UDim2.new(0, 130, 0, 200),
			})
		},
		noTextButton = {
			name = "No Text Button",
			story = Roact.createElement(InputButtonStory, {
				text = "",
				size = UDim2.new(0, 130, 0, 40),
			})
		},
	}
}