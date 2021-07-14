-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\Text\ImageTextLabel.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local ImageTextLabelRoot = script.Parent.Parent
local Text = ImageTextLabelRoot.Parent
local Core = Text.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent

local Images = require(UIBlox.App.ImageSet.Images)
local withStyle = require(UIBlox.Core.Style.withStyle)

local Roact = require(Packages.Roact)

local ImageTextLabel = require(ImageTextLabelRoot.ImageTextLabel)

local ImageTextLabelStory = Roact.PureComponent:extend("ImageTextLabelStory")

function ImageTextLabelStory:render()
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font

		local titleIcon = Images["icons/status/premium_small"]
		local titleIconSize = titleIcon.ImageRectSize / Images.ImagesResolutionScale

		return Roact.createElement(StoryItem, {
			size = UDim2.new(0, 300, 0, 128),
			layoutOrder = 1,
			title = "Image Text Label",
			subTitle = "Text.ImageTextLabel",
			showDivider = true,
		}, {
			verticalLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 10),
			}),
			OneLineNoIcon = Roact.createElement(ImageTextLabel, {
				genericTextLabelProps = {
					TextSize = 15,
					colorStyle = theme.TextEmphasis,
					fontStyle = font.Header2,
					Text = "One line with no Icon",
					TextTruncate = Enum.TextTruncate.AtEnd,
				},
				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				},
				padding = 4,
			}),
			OneLine = Roact.createElement(ImageTextLabel, {
				imageProps = {
					BackgroundTransparency = 1,
					Image = titleIcon,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					Size = UDim2.new(0, titleIconSize.X, 0, titleIconSize.Y),
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, 0, 0, 0),
				},
				genericTextLabelProps = {
					TextSize = 15,
					colorStyle = theme.TextEmphasis,
					fontStyle = font.Header2,
					Text = "One line with icon",
					TextTruncate = Enum.TextTruncate.AtEnd,
				},
				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				},
				padding = 4,
			}),
			TwoLinesNoIcon = Roact.createElement(ImageTextLabel, {
				genericTextLabelProps = {
					TextSize = 15,
					colorStyle = theme.TextEmphasis,
					fontStyle = font.Header2,
					Text = "Multiple lined text that should truncate at the end",
					TextTruncate = Enum.TextTruncate.AtEnd,
				},
				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = 3,
				},
				padding = 4,
				maxSize = Vector2.new(170, 40),
			}),
			TwoLines = Roact.createElement(ImageTextLabel, {
				imageProps = {
					BackgroundTransparency = 1,
					Image = titleIcon,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					Size = UDim2.new(0, titleIconSize.X, 0, titleIconSize.Y),
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, 0, 0, 0),
				},
				genericTextLabelProps = {
					TextSize = 15,
					colorStyle = theme.TextEmphasis,
					fontStyle = font.Header2,
					Text = "Multiple lined text that should truncate at the end",
					TextTruncate = Enum.TextTruncate.AtEnd,
				},
				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = 4,
				},
				padding = 4,
				maxSize = Vector2.new(170, 40),
			})
		})
	end)
end

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(ImageTextLabelStory),
	})

	local handle = Roact.mount(styleProvider, target, "ImageTextLabel")
	return function()
		Roact.unmount(handle)
	end
end