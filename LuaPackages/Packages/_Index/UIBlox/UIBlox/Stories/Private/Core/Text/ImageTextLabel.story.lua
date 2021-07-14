local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)

local Core = Packages.UIBlox.Core
local withStyle = require(Core.Style.withStyle)
local ImageTextLabel = require(Core.Text.ImageTextLabel.ImageTextLabel)

local ImageTextLabelStory = Roact.PureComponent:extend("ImageTextLabelStory")

function ImageTextLabelStory:render()
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font

		local titleIcon = Images["icons/status/premium_small"]
		local titleIconSize = titleIcon.ImageRectSize / Images.ImagesResolutionScale

		local props = self.props
		local text = props.Text
		local showIcon = props.ShowIcon

		return Roact.createElement(ImageTextLabel, {
			imageProps = showIcon and {
					BackgroundTransparency = 1,
					Image = titleIcon,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					Size = UDim2.new(0, titleIconSize.X, 0, titleIconSize.Y),
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, 0, 0, 0),
				} or nil,
				genericTextLabelProps = {
					TextSize = 15,
					colorStyle = theme.TextEmphasis,
					fontStyle = font.Header2,
					Text = text,
					TextTruncate = Enum.TextTruncate.AtEnd,
				},
				frameProps = {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				},
				padding = 4,
				maxSize = Vector2.new(170, 40),
		})
	end)
end

return {
	stories = {
		OneLineNoIcon = Roact.createElement(ImageTextLabelStory, {
			Text = "One line with no Icon",
			ShowIcon = false,
		}),
		OneLine = Roact.createElement(ImageTextLabelStory, {
			Text = "One line with icon",
			ShowIcon = true,
		}),
		TwoLinesNoIcon = Roact.createElement(ImageTextLabelStory, {
			Text = "Multiple lined text that should truncate at the end",
			ShowIcon = false,
		}),
		TwoLines = Roact.createElement(ImageTextLabelStory, {
			Text = "Multiple lined text that should truncate at the end",
			ShowIcon = true,
		}),
	}
}
