--[[
	Shows a tile which can be off or on

	Required Props:
		string Text: the text string on the bottom of the tile
		callback OnClick: parameters() function to call when the tile is clicked

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		UDim2 ImageSize: the size of the image to display
		number ZIndex: the z sorting order of the component
		boolean IsOn: is the tile rendered in the switched on state
		number LayoutOrder: render order of component in layout
		string Image: the image to display on the tile
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UI = Framework.UI
local Button = UI.Button
local TextLabel = UI.Decoration.TextLabel
local Image = UI.Decoration.Image
local Util = Framework.Util
local Typecheck = Util.Typecheck

local Tile = Roact.PureComponent:extend("Tile")
Typecheck.wrap(Tile, script)

function Tile:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder or 1
	local zIndex = props.ZIndex or 1
	local isOn = props.IsOn or false
	local text = props.Text
	local onClick = props.OnClick
	local theme = props.Stylizer
	local image = props.Image
	local imageSize = props.ImageSize or theme.ImageSize

	return Roact.createElement(Button, {
		Style = {
			Background = UI.Decoration.Box,
			BackgroundStyle = {
				Color = theme.ButtonBackgroundColor,
				BorderSize = 0,
				Transparency = isOn and 0 or 1,
			},
		},
		Size = theme.TileSize,
		Position = props.Position,
		LayoutOrder = layoutOrder,
		ZIndex = zIndex,
		OnClick = onClick,
	}, {
		ImageFrame = Roact.createElement("Frame", {
			Size = theme.ImageFrameSize,
			Position = UDim2.new(0, theme.TileInnerBorder.X, 0, theme.TileInnerBorder.Y),
			BackgroundColor3 = theme.ImageBackgroundColor,
			BorderSizePixel = 0,
			ZIndex = zIndex + 1,
		}, {
			Image = Roact.createElement(Image, {
				Style = {
					Image = image,
					Size = imageSize,
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
				},
			}),
		}),

		TextLabelFrame = Roact.createElement("Frame", {
			Size = theme.TextLabelSize,
			Position = UDim2.new(0, theme.TileInnerBorder.X, 1, -theme.TileInnerBorder.Y),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			ClipsDescendants = true,
		}, {
			TextLabel = Roact.createElement(TextLabel, {
				Text = text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = zIndex + 1,
				Size = UDim2.new(1, 0, 1, 0),
			})
		}),
	})
end

ContextServices.mapToProps(Tile,{
	Stylizer = ContextServices.Stylizer,
})

return Tile