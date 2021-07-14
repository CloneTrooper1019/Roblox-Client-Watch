-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\InputButton.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local InputButtonRoot = script.Parent.Parent
local Core = InputButtonRoot.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent

local withStyle = require(UIBlox.Core.Style.withStyle)
local Images = require(Packages.UIBlox.App.ImageSet.Images)
local Roact = require(Packages.Roact)
local InputButton = require(InputButtonRoot.InputButton)

local InputButtonStory = Roact.PureComponent:extend("InputButtonStory")

local function createButton(props)
	local theme = props.style.Theme.SystemPrimaryDefault

	return Roact.createElement(InputButton, {
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
		layoutOrder = props.layoutOrder,
	})
end

function InputButtonStory:render()
	return withStyle(function(style)
		return Roact.createElement(StoryItem, {
			layoutOrder = 1,
			title = "Input Button",
			subTitle = "InputButton.InputButton",
			showDivider = true,
		}, {
			layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 20),
			}),

			noTextButton = createButton({
				text = "",
				size = UDim2.new(0, 130, 0, 20),
				layoutOrder = 1,
				style = style,
			}),
			oneLineButton = createButton({
				text = "Text",
				size = UDim2.new(0, 130, 0, 20),
				layoutOrder = 2,
				style = style,
			}),
			twoLineButton = createButton({
				text = "Two lines of text",
				size = UDim2.new(0, 130, 0, 40),
				layoutOrder = 3,
				style = style,
			}),
			threeLineButton = createButton({
				text = "This has three lines of text",
				size = UDim2.new(0, 130, 0, 60),
				layoutOrder = 4,
				style = style,
			}),
			tenLineButton = createButton({
				text = "An example of the unreasonable amount of text wrapping we could do. This is 10 lines",
				size = UDim2.new(0, 130, 0, 200),
				layoutOrder = 5,
				style = style,
			}),
		})
	end)
end

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(InputButtonStory),
	})

	local handle = Roact.mount(styleProvider, target, "InputButton")
	return function()
		Roact.unmount(handle)
	end
end
