--[[
	This component handles the description rows of the assetPreview component.
	It's in charge of showing category name in the left and content in the right.

	Required Properties:
	Position = UDim2
	LeftContent = string, the name for the category.
	RightContent = string, the name of the category.

	Optional Properties:
	UseBoldLine = bool, decide if we bold the underlying line or not.
	HideSeparator = bool, whether or not to hide the separator after the component
	LayoutOrder = num
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)
local join = require(Library.join)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local AssetDescription = Roact.PureComponent:extend("AssetDescription")

function AssetDescription:render()
	return withTheme(function(theme)
		local props = self.props
		local position = props.Position or UDim2.new(1, 0, 1, 0)
		local leftContent = props.LeftContent or ""
		local rightContent = props.RightContent or ""

		local useBoldLine = props.UseBoldLine or false
		local hideSeparator = props.HideSeparator or false

		local descriptionTheme = theme.assetPreview.description

		local layoutOrder = props.LayoutOrder

		local children = join({
			-- Make sure left side and right side won't be cut off.
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 0),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 0),
			}),

			LeftContent = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),

				Text = leftContent,
				Font = theme.assetPreview.font,
				TextColor3 = descriptionTheme.leftTextColor,
				TextSize = theme.assetPreview.textSizeLarge,
				TextXAlignment = Enum.TextXAlignment.Left,

				BackgroundTransparency = 1,

				AutoLocalize = false,
			}),

			RightContent = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),

				Text = rightContent,
				Font = theme.assetPreview.font,
				TextColor3 = descriptionTheme.rightTextColor,
				TextSize = theme.assetPreview.textSizeLarge,
				TextXAlignment = Enum.TextXAlignment.Right,

				BackgroundTransparency = 1,

				AutoLocalize = false,
			}),

			ButtonLine = not hideSeparator and Roact.createElement("Frame", {
				Position = UDim2.new(0, 0, 1, 3),
				Size = UDim2.new(1, 0, 0, 1),

				BorderSizePixel = useBoldLine and 1 or 0,
				BackgroundColor3 = descriptionTheme.lineColor,
				BorderColor3 = descriptionTheme.lineColor,
			})
		}, props[Roact.Children] or {})

		return Roact.createElement("Frame", {
			Position = position,
			Size = UDim2.new(1, 0, 0, theme.assetPreview.description.height),

			BackgroundTransparency = 1,
			BackgroundColor3 = descriptionTheme.background,
			LayoutOrder = layoutOrder,
		}, children)
	end)
end

return AssetDescription
