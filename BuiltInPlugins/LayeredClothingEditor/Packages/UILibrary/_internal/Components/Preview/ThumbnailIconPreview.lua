--[[
	This component is the default shown for the 3D view in asset preview. This component shows the class
	icon for that instance and the name of the element.

	Necessary properties:
	Postion = UDim2
	Size = UDim2, this property determines the size of the preview.
	ElementName = String, the name of the asset, this will be displayed below the icon.
	TargetInstance = The instance to preview.

	Optional properties:
	IconSize = number, will default to 16 unless otherwise specified,
				this affects the dimensions of the icon representing the asset.
	TextLabelHeight = number
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local GetClassIcon = require(Library.Utils.GetClassIcon)

local ThumbnailIconPreview = Roact.PureComponent:extend("ThumbnailIconPreview")

function ThumbnailIconPreview:render()
	return withTheme(function(theme)
		local props = self.props

		local elementName = props.ElementName or ""
		local instance = props.TargetInstance
		local iconInfo = GetClassIcon(instance)

		local position = props.Position
		local size = props.Size or UDim2.new(1, 0, 1, 0)
		local thumbnailIconPreviewTheme = theme.assetPreview.thumbnailIconPreview
		local iconSize = props.IconSize or thumbnailIconPreviewTheme.iconSize
		local padding = thumbnailIconPreviewTheme.textLabelPadding
		local textLabelHeight = props.TextLabelHeight or thumbnailIconPreviewTheme.defaultTextLabelHeight

		local layoutOrder = props.LayoutOrder

		return Roact.createElement("Frame", {
			Position = position,
			Size = size,

			BackgroundTransparency = 0,
			BackgroundColor3 = thumbnailIconPreviewTheme.background,
			BorderSizePixel = 0,

			LayoutOrder = layoutOrder,
		},{
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			ImageContent = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, iconSize, 0, iconSize),

				BackgroundTransparency = 1,

				Image = iconInfo.Image,
				ImageRectSize = iconInfo.ImageRectSize,
				ImageRectOffset = iconInfo.ImageRectOffset,
				LayoutOrder = 1,
			}),

			TextContent = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -2 * padding, 0, textLabelHeight),

				Text = tostring(elementName),
				TextColor3 = thumbnailIconPreviewTheme.textColor,
				Font = theme.assetPreview.font,
				TextSize = theme.assetPreview.textSize,
				TextXAlignment = Enum.TextXAlignment.Center,

				BackgroundTransparency = 1,
				LayoutOrder = 2,
			})
		})
	end)
end

return ThumbnailIconPreview


