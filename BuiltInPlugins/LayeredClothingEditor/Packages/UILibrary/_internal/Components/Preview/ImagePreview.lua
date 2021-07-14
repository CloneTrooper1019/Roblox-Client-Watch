--[[
	This component is used to display a single image in an AssetPreview.

	Necessary properties:
	Position = UDim2
	Size = UDim2
	ImageContent = String, url/rbxassetid of the image object to shown,
				   e.g. http://www.roblox.com/asset/?id=<assetId>
				        rbxassetid://<assetId>
	ScaleType = Enum.ScaleType.*, scaling type to use
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local ImagePreview = Roact.PureComponent:extend("ImagePreview")

function ImagePreview:render()
	return withTheme(function(theme)
		local props = self.props
		local imageContent = props.ImageContent

		local position = props.Position
		local size = props.Size or UDim2.new(1, 0, 1, 0)

		local imagePreviewTheme = theme.assetPreview.imagePreview
		local scaleType = props.ScaleType or Enum.ScaleType.Fit

		local layoutOrder = props.LayoutOrder

		return Roact.createElement("Frame", {
			Position = position,
			Size = size,

			BackgroundTransparency = 0,
			BackgroundColor3 = imagePreviewTheme.background,
			BorderSizePixel = 0,

			LayoutOrder = layoutOrder,
		},{
			ImageContent = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				ScaleType = scaleType,

				BackgroundTransparency = 1,

				Image = imageContent,
			}),
		})
	end)
end

return ImagePreview