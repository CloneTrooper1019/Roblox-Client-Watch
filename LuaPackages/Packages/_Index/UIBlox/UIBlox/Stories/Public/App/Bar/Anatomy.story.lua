local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local FitFrame = require(Packages.FitFrame)
local FitTextLabel = FitFrame.FitTextLabel

local withStyle = require(Packages.UIBlox.Style.withStyle)

local App = Packages.UIBlox.App
local TextButton = require(App.Button.TextButton)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

local function ComponentDefinition(props)
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font

		return Roact.createElement(FitFrame.FitFrameVertical, {
			BackgroundTransparency = 1,
			width = UDim.new(0, 0),
			contentPadding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			LayoutOrder = props.LayoutOrder,
		}, {
			title = Roact.createElement("TextLabel", {
				TextXAlignment = Enum.TextXAlignment.Right,
				Font = font.CaptionBody.Font,
				TextSize = font.CaptionBody.RelativeSize * font.BaseSize,
				TextColor3 = theme.TextDefault.Color,
				TextTransparency = theme.TextDefault.Transparency,
				BackgroundTransparency = 1,
				Text = props.title,
			}),
			separator = Roact.createElement("Frame", {
				Size = UDim2.new(0, 2, 0, 45),
				BackgroundColor3 = theme.TextEmphasis.Color,
				BackgroundTransparency = theme.TextEmphasis.Transparency,
			}),
			children = Roact.createElement(FitFrame.FitFrameVertical, {
				BackgroundTransparency = 1,
				width = UDim.new(1, 0),
			}, props[Roact.Children])
		})
	end)
end

local function SampleHeader(props)
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font

		local themeMap = theme.TextEmphasis
		local fontMap = font.Header1

		return Roact.createElement(FitTextLabel, {
			width = FitTextLabel.Width.FitToText,
			Text = props.title,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = fontMap.Font,
			TextSize = fontMap.RelativeSize * font.BaseSize,
			TextColor3 = themeMap.Color,
			TextTransparency = themeMap.Transparency,
		})
	end)
end

return {
	name = "Header Bar:\nAnatomy",
	summary = "Icon Button and Text Button components WIP.",
	stories = {
		iconButton = Roact.createElement(ComponentDefinition, {
			title = "Icon Button",
			LayoutOrder = 1,
		}, {
			demo = Roact.createElement(IconButton, {
				icon = Images["icons/common/search"],
			}),
		}),
		textButton = Roact.createElement(ComponentDefinition, {
			title = "Text Button",
			LayoutOrder = 2,
		}, {
			demo = Roact.createElement(TextButton, {
				text = "Action 1",
				fontStyle = "Body",
			}),
		}),
		header = Roact.createElement(ComponentDefinition, {
			title = "Header",
			LayoutOrder = 2,
		}, {
			demo = Roact.createElement(SampleHeader, {
				title = "Title Case",
			}),
		}),
	}
}
